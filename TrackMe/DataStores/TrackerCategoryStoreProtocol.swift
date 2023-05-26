//
//  TrackerCategoryProtocol.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 01.05.2023.
//

import Foundation
protocol ITrackerCategoryStoreProtocol {
	var categories: [TrackerCategoryCoreData] {
		get
	}
	func setDelegate(delegateForStore: ITrackerCategoryStoreDelegate)
	func addNewCategory(_ trackerCategory: TrackerCategory) throws
	func deleteCategory(by id: String) throws
	func changeCategory(by id: String, trackerCategory: CategoryElementViewModel) throws
	func fetchCategory(by id: String) -> TrackerCategoryCoreData?
	func categoryListIsEmpty() -> Bool
}
