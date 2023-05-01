//
//  TrackerRecordStoreProtocol.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 01.05.2023.
//

import Foundation
protocol ITrackerRecordStoreProtocol {
	func add(_ trackerRecord: TrackerRecord, for tracker: TrackerCoreData) throws
}
