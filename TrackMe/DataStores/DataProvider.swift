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

protocol IDataProviderProtocol {
	var numberOfSections: Int { get }
	func numberOfRowsInSection(_ section: Int) -> Int
	func nameOfSection(_ section: Int) -> String
	
	func addTracker(_ record: Tracker, category: TrackerCategoryCoreData) throws
	func getTrackerCoreData(at indexPath: IndexPath) -> TrackerCoreData
	func getTrackerObject(at: IndexPath) -> Tracker?
	
	func countRecordForTracker(trackerID: String) -> Int
	func trackerTrackedToday(date: Date, trackerID: String) -> Bool
	func addTrackerRecord(_ trackerRecord: TrackerRecord, for tracker: TrackerCoreData) throws
	func deleteRecord(date: Date, trackerID: String)
	func deleteAllTrackers() throws
	
	func addNewCategory(_ trackerCategory: TrackerCategory) throws
	func fetchCategory(by id: String) -> TrackerCategoryCoreData?
	func deleteAllCategories() throws
	
	
	func fetchResultControllerIsEmpty() -> Bool
	func addFiltersForFetchResultController(searchControllerText searchString: String, currentDay day: Date) throws
}

// MARK: - DataProvider
final class DataProvider: NSObject {
	weak var delegate: IDataProviderDelegate?
	
	private let context: NSManagedObjectContext
	private let trackerStore: ITrackerStoreProtocol
	private let trackerCategoryStore: ITrackerCategoryStoreProtocol
	private let trackerRecordStore: ITrackerRecordStoreProtocol
	
	private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {

		let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
		fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerCoreData.category?.name, ascending: true)]
		
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
	
	func getTrackerCoreData(at indexPath: IndexPath) -> TrackerCoreData {
		fetchedResultsController.object(at: indexPath)
	}

	func addTracker(_ record: Tracker, category: TrackerCategoryCoreData) throws {
		do {
			try trackerStore.addNewTracker(record, in: category)
		} catch {
			throw StoreErrors.addElementToDBError(error)
		}
	}
	
	func deleteAllTrackers() throws {
		do {
			try trackerStore.deleteAllTrackers()
		} catch {
			throw StoreErrors.deleteElementError
		}
	}
	
//	func changeTracker(by id: String, tracker: Tracker) throws {
//		guard let category = fetchCategory(by: tracker.) else {
//			return
//		}
//		trackerStore.changeTracker(by: id,
//								   tracker: tracker,
//								   category: category)
//	}
	
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
	
	func addFiltersForFetchResultController(searchControllerText searchString: String, currentDay day: Date) throws {
		let dayNumber = WeekDay.getWeekDayInNumber(for: day)
		var predicates: [NSPredicate] = []
		
		let predicateForDate = NSPredicate(format: "%K CONTAINS[n] %@", #keyPath(TrackerCoreData.schedule), dayNumber)
		predicates.append(predicateForDate)
		
		if !searchString.isEmpty {
			let predicateForSearchController = NSPredicate(format: "%K CONTAINS[n] %@", #keyPath(TrackerCoreData.name), searchString)
			predicates.append(predicateForSearchController)
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
