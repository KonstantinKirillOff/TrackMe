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

	func add(_ trackerCategory: TrackerCategory) throws -> TrackerCategoryCoreData {
		let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
		trackerCategoryCoreData.name = trackerCategory.name
		
		do {
			try context.save()
			return trackerCategoryCoreData
		} catch {
			throw StoreErrors.addElementToDBError(error)
		}
	}
	
	func fetchCategory(by name: String) -> TrackerCategoryCoreData? {
		let request = TrackerCategoryCoreData.fetchRequest()
		request.fetchLimit = 1
		request.returnsObjectsAsFaults = false
		request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryCoreData.name), name)
		
		guard let categories = try? context.fetch(request) else { return nil }
		return categories.first
	}

}
