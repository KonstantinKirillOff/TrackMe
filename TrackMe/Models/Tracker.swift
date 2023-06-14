//
//  Tracker.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 13.04.2023.
//

import UIKit

struct Tracker {
	let id: UUID
	let name: String
	let color: UIColor
	let emoji: String
	let schedule: Set<String>
	let isHabit: Bool
	let idCategoryBeforePin: String?
	let isPinned: Bool
}

enum PinStatus {
	case pinned
	case unpinned
}

struct TrackerCategory {
	let id: UUID
	let name: String
	let trackers: [Tracker]
}

struct TrackerRecord: Hashable {
	let id: UUID
	let date: Date
}
