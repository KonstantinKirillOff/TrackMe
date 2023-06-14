//
//  CategoryViewModel.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 18.05.2023.
//

import Foundation

@objcMembers
final class CategoryViewModel: NSObject {
	dynamic private(set) var categoryNameIsEmpty: Bool = true
	private let model: CategoryModel
	
	init(for model: CategoryModel) {
		self.model = model
	}
	
	func checkCategoryName(name: String?) {
		categoryNameIsEmpty = model.categoryNameIsEmpty(name)
	}
	
	func addNewCategory(category: TrackerCategory) {
		model.addNewCategory(category: category)
	}
}
