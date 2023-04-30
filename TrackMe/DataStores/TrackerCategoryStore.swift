//
//  TrackerCategoryStore.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 30.04.2023.
//

import UIKit
import CoreData

struct CategoryStoreUpdate {
	let insertedIndexes: IndexSet
	let updatedIndexes: IndexSet
}

protocol CategoryStoreDelegate: AnyObject {
	func store(_ store: TrackerCategoryStore, didUpdate update: CategoryStoreUpdate)
}

final class TrackerCategoryStore: NSObject {
	private let context: NSManagedObjectContext
	private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {

		let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
		
		let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
																  managedObjectContext: context,
																  sectionNameKeyPath: nil,
																  cacheName: nil)
		fetchedResultsController.delegate = self
		try? fetchedResultsController.performFetch()
		return fetchedResultsController
	}()

	weak var delegate: CategoryStoreDelegate?
	private var insertedIndexes: IndexSet?
	private var updatedIndexes: IndexSet?

	convenience override init() {
		let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
		try! self.init(context: context)
	}

	init(context: NSManagedObjectContext) throws {
		self.context = context
		super.init()

	}

	func addNewCategory(_ trackerCategory: TrackerCategory) throws {
		let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
		updateExistingTrackerCategory(trackerCategoryCoreData, with: trackerCategory)
		try context.save()
	}

	func updateExistingTrackerCategory(_ trackerCategoryCoreData: TrackerCategoryCoreData, with category: TrackerCategory) {
		trackerCategoryCoreData.name = category.name
		//ToDo trackers
	}

}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
	func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		insertedIndexes = IndexSet()
		updatedIndexes = IndexSet()
	}

	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		delegate?.store(self, didUpdate: CategoryStoreUpdate(insertedIndexes: insertedIndexes!,
															 updatedIndexes: updatedIndexes!))
		insertedIndexes = nil
		updatedIndexes = nil
	}

	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
					didChange anObject: Any,
					at indexPath: IndexPath?,
					for type: NSFetchedResultsChangeType,
					newIndexPath: IndexPath?) {
		switch type {
		case .insert:
			guard let indexPath = newIndexPath else { fatalError() }
			insertedIndexes?.insert(indexPath.item)
		case .update:
			guard let indexPath = indexPath else { fatalError() }
			updatedIndexes?.insert(indexPath.item)
		default:
			fatalError()
		}
	}
}
