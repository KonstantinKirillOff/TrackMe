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
	
	//func deleteRecord(date: Date, trackerID: String)
}
