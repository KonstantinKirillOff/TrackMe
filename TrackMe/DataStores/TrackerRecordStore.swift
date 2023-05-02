//
//  TrackerRecordStore.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 30.04.2023.
//

import UIKit
import CoreData

final class TrackerRecordStore: NSObject, ITrackerRecordStoreProtocol {
	private let context: NSManagedObjectContext
	
	override init() {
		self.context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
	}
	
	func add(_ trackerRecord: TrackerRecord, for tracker: TrackerCoreData) throws {
		let trackerRecordCoreData = TrackerRecordCoreData(context: context)
		trackerRecordCoreData.date = trackerRecord.date
		trackerRecordCoreData.tracker = tracker
		try context.save()
	}
	
	func deleteRecord(date: Date, trackerID: String) {
		let request = TrackerRecordCoreData.fetchRequest()
		request.returnsObjectsAsFaults = false
		request.predicate = NSPredicate(format: "%K == %@ AND %K == %@",
										#keyPath(TrackerRecordCoreData.tracker.trackerID), trackerID,
										#keyPath(TrackerRecordCoreData.date), date as NSDate
		)
		guard let recordsForTacker = try? context.fetch(request) else { return }
		recordsForTacker.forEach { trackerRecordCoreData in
			context.delete(trackerRecordCoreData)
		}
	}
	
	func trackerTrackedToday(date: Date, trackerID: String) -> Bool {
		let request = TrackerRecordCoreData.fetchRequest()
		request.returnsObjectsAsFaults = false
		request.predicate = NSPredicate(format: "%K == %@ AND %K == %@",
										#keyPath(TrackerRecordCoreData.tracker.trackerID), trackerID,
										#keyPath(TrackerRecordCoreData.date), date as NSDate
		)
		guard let recordsForTacker = try? context.fetch(request) else { return false }
		return !recordsForTacker.isEmpty
   }
	
	func countRecordForTracker(trackerID: String) -> Int {
		let request = TrackerRecordCoreData.fetchRequest()
		request.returnsObjectsAsFaults = true
		request.predicate = NSPredicate(format: "%K == %@",
										#keyPath(TrackerRecordCoreData.tracker.trackerID), trackerID
		)
		guard let recordCount = try? context.fetch(request) else { return 0 }
		return recordCount.count
	}
}
