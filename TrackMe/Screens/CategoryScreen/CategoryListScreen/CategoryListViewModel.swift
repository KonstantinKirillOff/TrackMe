//
//  CategoryListViewModel.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 19.05.2023.
//

import Foundation

final class CategoryListViewModel {
	private(set) var categories: [TrackerCategory] = []
	private(set) var selectedCategory: TrackerCategory?
	
	private let model: CategoryListModel
	
	init(for model: CategoryListModel) {
		self.model = model
	}
	
	func selectCategory(category: TrackerCategory) {
		selectCategory(category: category)
	}
}
