//
//  ITrackerStoreProtocol.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 01.05.2023.
//

import Foundation
protocol ITrackerStoreProtocol {
	func addNewTracker(_ tracker: Tracker, in category: TrackerCategoryCoreData) throws
	func deleteTracker(by id: String) throws
	func deleteAllTrackers() throws
	func fetchTracker(by id: String) -> TrackerCoreData?
	func changeTracker(by id: String, tracker: Tracker, category: TrackerCategoryCoreData) throws
	func tracker(from trackerCoreData: TrackerCoreData) throws -> Tracker
}
