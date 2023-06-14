//
//  DataProvider.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 01.05.2023.
//

import UIKit
import CoreData

enum StoreErrors: Error {
	case badRequestToDB
	case failedToInitializeContext
	case addElementToDBError(Error)
	case readElementFromDBError(Error)
	case saveContextError
	case changeElementError
	case deleteElementError
}

protocol IDataProviderDelegate: AnyObject {
	func trackersStoreDidUpdate()
}

protocol DataProviderStatisticProtocol: AnyObject {
	var isTrackersInCoreData: Bool { get }
	func getCountCompletedTrackers() -> Int
}

protocol IDataProviderProtocol {
	var numberOfSections: Int { get }
	func numberOfRowsInSection(_ section: Int) -> Int
	func nameOfSection(_ section: Int) -> String
	
	func addTracker(_ record: Tracker, category: TrackerCategoryCoreData) throws
	func changeTracker(tracker: Tracker, category: TrackerCategoryCoreData) throws
	func getTrackerCoreData(at indexPath: IndexPath) -> TrackerCoreData?
	func fetchTracker(by id: String) -> TrackerCoreData?
	func getTrackerObject(at: IndexPath) -> Tracker?
	
	func countRecordForTracker(trackerID: String) -> Int
	func trackerTrackedToday(date: Date, trackerID: String) -> Bool
	func addTrackerRecord(_ trackerRecord: TrackerRecord, for tracker: TrackerCoreData) throws
	func deleteRecord(date: Date, trackerID: String)
	func deleteAllTrackers() throws
	func deleteTracker(by id: String) throws
	
	func addNewCategory(_ trackerCategory: TrackerCategory) throws
	func fetchCategory(by id: String) -> TrackerCategoryCoreData?
	func deleteAllCategories() throws
	
	
	func fetchResultControllerIsEmpty() -> Bool
	func addFiltersForFetchResultController(searchControllerText searchString: String, currentDay day: Date, filtersForTrackerList: FilterType) throws
	
	func changePinStatusForTracker(tracker: Tracker, pinStatus: PinStatus) throws
}

// MARK: - DataProvider
final class DataProvider: NSObject {
	weak var delegate: IDataProviderDelegate?
	
	private let settingsManager = SettingsManager.shared
	private let context: NSManagedObjectContext
	private let trackerStore: ITrackerStoreProtocol
	private let trackerCategoryStore: ITrackerCategoryStoreProtocol
	private let trackerRecordStore: ITrackerRecordStoreProtocol
	
	private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {

		let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
		fetchRequest.sortDescriptors = [
			NSSortDescriptor(keyPath: \TrackerCoreData.category?.createdAt, ascending: true)
		]
		let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
																  managedObjectContext: context,
																  sectionNameKeyPath: #keyPath(TrackerCoreData.category.name),
																  cacheName: nil)
		fetchedResultsController.delegate = self
		try? fetchedResultsController.performFetch()
		return fetchedResultsController
	}()
	
	init(_ trackerStore: ITrackerStoreProtocol, _ trackerCategoryStore: ITrackerCategoryStoreProtocol, _ trackerRecordStore: ITrackerRecordStoreProtocol, delegate: IDataProviderDelegate) {
		self.delegate = delegate
		self.context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
		self.trackerStore = trackerStore
		self.trackerRecordStore = trackerRecordStore
		self.trackerCategoryStore = trackerCategoryStore
	}
}

// MARK: - DataProviderProtocol
extension DataProvider: IDataProviderProtocol {
	var numberOfSections: Int {
		fetchedResultsController.sections?.count ?? 0
	}
	
	func numberOfRowsInSection(_ section: Int) -> Int {
		fetchedResultsController.sections?[section].numberOfObjects ?? 0
	}
	
	func nameOfSection(_ section: Int) -> String {
		fetchedResultsController.sections?[section].name ?? ""
	}
	
	func getTrackerObject(at indexPath: IndexPath) -> Tracker? {
		let trackerCoreData = fetchedResultsController.object(at: indexPath)
		guard let tracker = try? trackerStore.tracker(from: trackerCoreData) else { return nil }
		return tracker
	}
	
	func getTrackerCoreData(at indexPath: IndexPath) -> TrackerCoreData? {
		fetchedResultsController.object(at: indexPath)
	}
	
	func fetchTracker(by id: String) -> TrackerCoreData? {
		trackerStore.fetchTracker(by: id)
	}

	func addTracker(_ record: Tracker, category: TrackerCategoryCoreData) throws {
		do {
			try trackerStore.addNewTracker(record, in: category)
		} catch {
			throw StoreErrors.addElementToDBError(error)
		}
	}
	
	func changeTracker(tracker: Tracker, category: TrackerCategoryCoreData) throws {
		do {
			try trackerStore.changeTracker(tracker: tracker, category: category)
		} catch {
			throw StoreErrors.changeElementError
		}
	}
	
	func changePinStatusForTracker(tracker: Tracker, pinStatus: PinStatus) throws {
		guard let trackerCoreData = trackerStore.fetchTracker(by: tracker.id.uuidString) else { return }
		
		switch pinStatus {
		case .pinned:
			trackerCoreData.category = trackerCategoryStore.fetchCategory(by: settingsManager.pinnedCategoryId)
			trackerCoreData.isPinned = true
		case .unpinned:
			guard let idCategoryBeforePin = tracker.idCategoryBeforePin else { return }
			trackerCoreData.category = trackerCategoryStore.fetchCategory(by: idCategoryBeforePin)
			trackerCoreData.isPinned = false
		}
		try context.save()
		try fetchedResultsController.performFetch()
	}
	
	func deleteAllTrackers() throws {
		do {
			try trackerStore.deleteAllTrackers()
		} catch {
			throw StoreErrors.deleteElementError
		}
	}
	
	func deleteTracker(by id: String) throws {
		do {
			try trackerStore.deleteTracker(by: id)
		} catch {
			throw StoreErrors.deleteElementError
		}
	}
	
	func addNewCategory(_ trackerCategory: TrackerCategory) throws {
		do {
			try trackerCategoryStore.addNewCategory(trackerCategory)
		} catch {
			throw StoreErrors.addElementToDBError(error)
		}
	}
	
	func deleteAllCategories() throws {
		do {
			try trackerCategoryStore.deleteAllCategories()
		} catch {
			throw StoreErrors.deleteElementError
		}
	}
	
	func fetchCategory(by id: String) -> TrackerCategoryCoreData? {
		trackerCategoryStore.fetchCategory(by: id)
	}
	
	func fetchResultControllerIsEmpty() -> Bool {
		fetchedResultsController.fetchedObjects?.count == 0
	}
	
	func addFiltersForFetchResultController(searchControllerText searchString: String, currentDay day: Date, filtersForTrackerList: FilterType) throws {
		let dayNumber = WeekDay.getWeekDayInNumber(for: day)
		var predicates: [NSPredicate] = []
		
		if !searchString.isEmpty {
			let predicateForSearchController = NSPredicate(format: "%K CONTAINS[n] %@",
														   #keyPath(TrackerCoreData.name),
														   searchString)
			predicates.append(predicateForSearchController)
		}
		
		switch filtersForTrackerList {
		case .completed:
			let completedPredicate = NSPredicate(format: "records.date CONTAINS[cd] %@",
												 day as NSDate)
			predicates.append(completedPredicate)
		case .notCompleted:
			let notCompletedPredicate = NSPredicate(format: "%K.@count == 0",
													#keyPath(TrackerCoreData.records))
			predicates.append(notCompletedPredicate)
		case .trackersForToday:
			let predicateForDate = NSPredicate(format: "%K CONTAINS[n] %@",
											   #keyPath(TrackerCoreData.schedule),
											   dayNumber)
			predicates.append(predicateForDate)
		case .allTrackers:
			break
		}
		
		do {
			fetchedResultsController.fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
			try fetchedResultsController.performFetch()
		} catch {
			throw StoreErrors.badRequestToDB
		}
	}
	
	func countRecordForTracker(trackerID: String) -> Int {
		trackerRecordStore.countRecordForTracker(trackerID: trackerID)
	}
	
	func trackerTrackedToday(date: Date, trackerID: String) -> Bool {
		trackerRecordStore.trackerTrackedToday(date: date, trackerID: trackerID)
	}
	
	func addTrackerRecord(_ trackerRecord: TrackerRecord, for tracker: TrackerCoreData) throws {
		do {
			try trackerRecordStore.addNewRecord(trackerRecord, for: tracker)
		} catch {
			throw StoreErrors.addElementToDBError(error)
		}
	}
	
	func deleteRecord(date: Date, trackerID: String) {
		trackerRecordStore.deleteRecord(date: date, trackerID: trackerID)
	}
}

// MARK: - NSFetchedResultsControllerDelegate
extension DataProvider: NSFetchedResultsControllerDelegate {
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		delegate?.trackersStoreDidUpdate()
	}
}

extension DataProvider: DataProviderStatisticProtocol {
	func getCountCompletedTrackers() -> Int {
		trackerRecordStore.finishedTrackersForDate(date: Date().getDayWithoutTime()).count
	}
	
	var isTrackersInCoreData: Bool {
		let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
		let result = try? context.fetch(fetchRequest)
		guard let isEmpty = result?.isEmpty else { return false }
		return !isEmpty
	}
}
