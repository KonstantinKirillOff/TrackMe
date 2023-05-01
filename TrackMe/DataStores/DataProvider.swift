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
}

struct TrackerStoreUpdate {
	let insertedIndexes: [IndexPath]
}

protocol IDataProviderDelegate: AnyObject {
	func trackersStoreDidUpdate(_ update: TrackerStoreUpdate)
}

protocol IDataProviderProtocol {
	var numberOfSections: Int { get }
	func numberOfRowsInSection(_ section: Int) -> Int
	func nameOfSection(_ section: Int) -> String
	
	func getTrackerObject(at: IndexPath) -> Tracker
	
	func addTracker(_ record: Tracker, category: TrackerCategoryCoreData) throws
	func addCategory(_ category: TrackerCategory) throws -> TrackerCategoryCoreData
	
	func fetchCategory(by name: String) -> TrackerCategoryCoreData?
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
	private var insertedIndexes: [IndexPath]?
	
	private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {

		let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
		fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerCoreData.category, ascending: true)]
		
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
	
	func getTrackerObject(at indexPath: IndexPath) -> Tracker {
		let trackerCoreData = fetchedResultsController.object(at: indexPath)
		return Tracker(id: UUID(uuidString: trackerCoreData.id!)!,
					   name: trackerCoreData.name!,
					   color: UIColor.color(fromHex: trackerCoreData.hexColor!),
					   emoji: trackerCoreData.emoji!,
					   schedule: Set(trackerCoreData.schedule!.components(separatedBy: ",")))
	}

	func addTracker(_ record: Tracker, category: TrackerCategoryCoreData) throws {
		try? trackerStore.add(record, in: category)
	}
	
	func addCategory(_ category: TrackerCategory) throws -> TrackerCategoryCoreData {
		do {
			let newCategory =  try trackerCategoryStore.add(category)
			return newCategory
		} catch {
			throw StoreErrors.addElementToDBError(error)
		}
	}
	
	func fetchCategory(by name: String) -> TrackerCategoryCoreData? {
		trackerCategoryStore.fetchCategory(by: name)
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
}

// MARK: - NSFetchedResultsControllerDelegate
extension DataProvider: NSFetchedResultsControllerDelegate {
	func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		insertedIndexes = []
	}

	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		delegate?.trackersStoreDidUpdate(TrackerStoreUpdate(insertedIndexes: insertedIndexes!))
		insertedIndexes = nil
	}
	
	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
		
		switch type {
		case .insert:
			if let indexPath = newIndexPath {
				insertedIndexes?.append(indexPath)
			}
		default:
			break
		}
	}
}
