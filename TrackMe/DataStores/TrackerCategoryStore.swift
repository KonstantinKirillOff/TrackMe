//
//  TrackerCategoryStore.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 30.04.2023.
//

import UIKit
import CoreData

final class TrackerCategoryStore: NSObject, ITrackerCategoryStoreProtocol {
	private let context: NSManagedObjectContext
	
	override init() {
		self.context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
	}

	func addNewCategory(_ trackerCategory: TrackerCategory) throws {
		let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
		trackerCategoryCoreData.categoryID = trackerCategory.id.uuidString
		trackerCategoryCoreData.name = trackerCategory.name
		try context.save()
	}
	
	func deleteCategory(by id: String) {
		let request = TrackerCategoryCoreData.fetchRequest()
		request.returnsObjectsAsFaults = false
		request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryCoreData.categoryID), id)
	
		guard let categoriesForDeleting = try? context.fetch(request) else { return }
		categoriesForDeleting.forEach { category in
			context.delete(category)
		}
	}
	
	func fetchCategory(by id: String) -> TrackerCategoryCoreData? {
		let request = TrackerCategoryCoreData.fetchRequest()
		request.fetchLimit = 1
		request.returnsObjectsAsFaults = false
		request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryCoreData.categoryID), id)
		
		guard let categories = try? context.fetch(request) else { return nil }
		return categories.first
	}
	
	func changeCategory(by id: String, trackerCategory: TrackerCategory) throws {
		let request = TrackerCategoryCoreData.fetchRequest()
		request.returnsObjectsAsFaults = false
		request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryCoreData.categoryID), id)
		
		guard let categories = try? context.fetch(request) else { return }
		if let categoryForChange = categories.first {
			categoryForChange.categoryID = trackerCategory.id.uuidString
			categoryForChange.name = trackerCategory.name
			try context.save()
		}
	}
}
