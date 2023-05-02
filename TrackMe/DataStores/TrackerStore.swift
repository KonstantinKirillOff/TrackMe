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
	
	func add(_ tracker: Tracker, in category: TrackerCategoryCoreData) throws {
		let trackerCoreData = TrackerCoreData(context: context)
		trackerCoreData.trackerID = tracker.id.uuidString
		trackerCoreData.name = tracker.name
		trackerCoreData.emoji = tracker.emoji
		trackerCoreData.hexColor = tracker.color.toHexString
		trackerCoreData.schedule = Array(tracker.schedule).joined(separator: ",")
		trackerCoreData.category = category
		try context.save()
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
