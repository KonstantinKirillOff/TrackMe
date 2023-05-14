//
//  TrackerCategoryProtocol.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 01.05.2023.
//

import Foundation
protocol ITrackerCategoryStoreProtocol {
	func add(_ trackerCategory: TrackerCategory) throws -> TrackerCategoryCoreData
	func fetchCategory(by name: String) -> TrackerCategoryCoreData?
}
