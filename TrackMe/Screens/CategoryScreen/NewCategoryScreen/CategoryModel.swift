//
//  CategoryModel.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 18.05.2023.
//

import Foundation

protocol ICategoryModelProtocol {
	func categoryNameIsEmpty(_ string: String?) -> Bool
	func addNewCategory(category: TrackerCategory)
}

final class CategoryModel: ICategoryModelProtocol {
	private let categoryStore: ITrackerCategoryStoreProtocol
	
	init(categoryStore: ITrackerCategoryStoreProtocol) {
		self.categoryStore = categoryStore
	}
	
	func categoryNameIsEmpty(_ string: String?) -> Bool {
		guard let string = string else { return true }
		return string.isEmpty
	}
	
	func addNewCategory(category: TrackerCategory) {
		try? categoryStore.addNewCategory(category)
	}
}
