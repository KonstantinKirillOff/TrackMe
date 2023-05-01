//
//  TrackerStore.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 30.04.2023.
//

import UIKit
import CoreData

final class TrackerStore: NSObject, ITrackerStoreProtocol {
	private let context: NSManagedObjectContext
	
	override init() {
		self.context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
	}
	
	func add(_ tracker: Tracker, in category: TrackerCategoryCoreData) throws {
		let trackerCoreData = TrackerCoreData(context: context)
		trackerCoreData.id = tracker.id.uuidString
		trackerCoreData.name = tracker.name
		trackerCoreData.emoji = tracker.emoji
		trackerCoreData.hexColor = tracker.color.toHexString
		trackerCoreData.schedule = Array(tracker.schedule).joined(separator: ",")
		trackerCoreData.category = category
		try context.save()
	}
		
}
