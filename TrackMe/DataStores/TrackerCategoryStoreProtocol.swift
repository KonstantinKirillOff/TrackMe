//
//  TrackerCategoryProtocol.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 01.05.2023.
//

import Foundation
protocol ITrackerCategoryStoreProtocol {
	func addNewCategory(_ trackerCategory: TrackerCategory) throws
	func deleteCategory(by id: String)
	func changeCategory(by id: String, trackerCategory: TrackerCategory) throws
	func fetchCategory(by id: String) -> TrackerCategoryCoreData?
}
