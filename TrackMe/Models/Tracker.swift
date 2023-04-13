//
//  Tracker.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 13.04.2023.
//

import UIKit

struct Tracker {
	let id: UUID = UUID()
	let name: String
	let color: UIColor
	let emoji: String
	let schedule: [Int]
}

struct TrackerCategory {
	let name: String
	let trackers: [Tracker]
}

struct TrackerRecord {
	let id: UUID
	let date: Date
}
