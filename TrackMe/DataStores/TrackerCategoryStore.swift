//
//  TrackerCategoryStore.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 30.04.2023.
//

import UIKit
import CoreData

protocol ITrackerCategoryStoreDelegate: AnyObject {
	func categoriesDidUpdate()
}

final class TrackerCategoryStore: NSObject, ITrackerCategoryStoreProtocol {
	var categories: [TrackerCategoryCoreData] {
		return self.fetchedResultsController.fetchedObjects ?? []
	}
	
	weak var delegate: ITrackerCategoryStoreDelegate?
	
	private let context: NSManagedObjectContext
	
	private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {

		let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
		fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerCategoryCoreData.name, ascending: true)]
		
		let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
																  managedObjectContext: context,
																  sectionNameKeyPath: nil,
																  cacheName: nil)
		fetchedResultsController.delegate = self
		try? fetchedResultsController.performFetch()
		return fetchedResultsController
	}()
	
	init(context: NSManagedObjectContext) {
		self.context = context
	}
	
	convenience override init() {
		let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
		self.init(context: context)
		
		let pinnedCategoryIsCreated = UserDefaults.standard.bool(forKey: Constants.pinnedCategoryIsCreatedKey)
		if !pinnedCategoryIsCreated {
			self.createPinnedCategory()
		}
	}
	
	private func createPinnedCategory() {
		let id = UUID()
		let trackerCategory = TrackerCategory(id: id,
											  name: "Закрепленные",
											  trackers: [])
		do {
			try addNewCategory(trackerCategory)
			UserDefaults.standard.set(true, forKey: Constants.pinnedCategoryIsCreatedKey)
			UserDefaults.standard.set(id.uuidString, forKey: Constants.pinnedCategoryIdKey)
		} catch {
			//TODO: handle error
		}
	}
	
	func setDelegate(delegateForStore: ITrackerCategoryStoreDelegate) {
		delegate = delegateForStore
	}

	func addNewCategory(_ trackerCategory: TrackerCategory) throws {
		let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
		trackerCategoryCoreData.categoryID = trackerCategory.id.uuidString
		trackerCategoryCoreData.name = trackerCategory.name
		try context.save()
	}
	
	func deleteCategory(by id: String) throws {
		let request = TrackerCategoryCoreData.fetchRequest()
		request.returnsObjectsAsFaults = false
		request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryCoreData.categoryID), id)
	
		guard let categoriesForDeleting = try? context.fetch(request) else { return }
		categoriesForDeleting.forEach { category in
			context.delete(category)
		}
		try context.save()
	}
	
	func deleteAllCategories() throws {
		let request = TrackerCategoryCoreData.fetchRequest()
		request.returnsObjectsAsFaults = false
	
		guard let categoriesForDeleting = try? context.fetch(request) else { return }
		categoriesForDeleting.forEach { category in
			context.delete(category)
		}
		try context.save()
	}
	
	func fetchCategory(by id: String) -> TrackerCategoryCoreData? {
		let request = TrackerCategoryCoreData.fetchRequest()
		request.fetchLimit = 1
		request.returnsObjectsAsFaults = false
		request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryCoreData.categoryID), id)
		
		guard let categories = try? context.fetch(request) else { return nil }
		return categories.first
	}
	
	func changeCategory(by id: String, trackerCategory: CategoryElementViewModel) throws {
		let request = TrackerCategoryCoreData.fetchRequest()
		request.returnsObjectsAsFaults = false
		request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryCoreData.categoryID), id)
		
		guard let categories = try? context.fetch(request) else { return }
		if let categoryForChange = categories.first {
			categoryForChange.categoryID = trackerCategory.id
			categoryForChange.name = trackerCategory.name
			try context.save()
		}
	}
	
	func categoryListIsEmpty() -> Bool {
		fetchedResultsController.fetchedObjects?.count == 0
	}
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		delegate?.categoriesDidUpdate()
	}
}
