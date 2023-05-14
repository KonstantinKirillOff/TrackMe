//
//  TrackerRecordStoreProtocol.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 01.05.2023.
//

import Foundation
protocol ITrackerRecordStoreProtocol {
	func add(_ trackerRecord: TrackerRecord, for tracker: TrackerCoreData) throws
	func deleteRecord(date: Date, trackerID: String)
	func trackerTrackedToday(date: Date, trackerID: String) -> Bool
	func countRecordForTracker(trackerID: String) -> Int
}
