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
	
	private enum TrackerStoreError: Error {
		case decodingErrorInvalidEmoji
		case decodingErrorInvalidColor
		case decodingErrorInvalidID
		case decodingErrorInvalidName
		case decodingErrorInvalidSchedule
	}
	
	override init() {
		self.context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
	}
	
	func addNewTracker(_ tracker: Tracker, in category: TrackerCategoryCoreData) throws {
		let trackerCoreData = TrackerCoreData(context: context)
		trackerCoreData.trackerID = tracker.id.uuidString
		trackerCoreData.name = tracker.name
		trackerCoreData.emoji = tracker.emoji
		trackerCoreData.hexColor = tracker.color.toHexString
		trackerCoreData.schedule = Array(tracker.schedule).joined(separator: ",")
		trackerCoreData.category = category
		try context.save()
	}
	
	func deleteTracker(by id: String) throws {
		let request = TrackerCoreData.fetchRequest()
		request.returnsObjectsAsFaults = false
		request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCoreData.trackerID), id)
	
		guard let trackersForDeleting = try? context.fetch(request) else { return }
		trackersForDeleting.forEach { tracker in
			context.delete(tracker)
		}
		try context.save()
	}
	
	func deleteAllTrackers() throws {
		let request = TrackerCoreData.fetchRequest()
		request.returnsObjectsAsFaults = false
	
		guard let trackersForDeleting = try? context.fetch(request) else { return }
		trackersForDeleting.forEach { tracker in
			context.delete(tracker)
		}
		try context.save()
	}
	
	func fetchTracker(by id: String) -> TrackerCoreData? {
		let request = TrackerCoreData.fetchRequest()
		request.fetchLimit = 1
		request.returnsObjectsAsFaults = false
		request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCoreData.trackerID), id)
		
		guard let trackers = try? context.fetch(request) else { return nil }
		return trackers.first
	}
	
	func changeTracker(by id: String, tracker: Tracker, category: TrackerCategoryCoreData) throws {
		let request = TrackerCoreData.fetchRequest()
		request.returnsObjectsAsFaults = false
		request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCoreData.trackerID), id)
		
		guard let trackers = try? context.fetch(request) else { return }
		if let trackerForChange = trackers.first {
			trackerForChange.trackerID = tracker.id.uuidString
			trackerForChange.name = tracker.name
			trackerForChange.emoji = tracker.emoji
			trackerForChange.hexColor = tracker.color.toHexString
			trackerForChange.schedule = Array(tracker.schedule).joined(separator: ",")
			trackerForChange.category = category
			try context.save()
		}
	}
	
	func tracker(from trackerCoreData: TrackerCoreData) throws -> Tracker {
		guard let emojies = trackerCoreData.emoji else {
			throw TrackerStoreError.decodingErrorInvalidEmoji
		}
		guard let colorHex = trackerCoreData.hexColor else {
			throw TrackerStoreError.decodingErrorInvalidColor
		}
		guard let trackerID = trackerCoreData.trackerID else {
			throw TrackerStoreError.decodingErrorInvalidID
		}
		guard let name = trackerCoreData.name else {
			throw TrackerStoreError.decodingErrorInvalidName
		}
		guard let schedule = trackerCoreData.schedule else {
			throw TrackerStoreError.decodingErrorInvalidSchedule
		}
		return Tracker(id: UUID(uuidString: trackerID)!,
					   name: name,
					   color: UIColor.color(fromHex: colorHex),
					   emoji: emojies,
					   schedule: Set(schedule.components(separatedBy: ",")))
	}
		
}
