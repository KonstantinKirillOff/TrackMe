//
//  CategoryListViewModel.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 19.05.2023.
//

import Foundation

final class CategoryListViewModel {
	@Observable
	private(set) var categories: [CategoryElementViewModel] = []
	
	private(set) var selectedCategory: CategoryElementViewModel?
	private let categoryStore: ITrackerCategoryStoreProtocol
	
	init(categoryStore: ITrackerCategoryStoreProtocol) {
		self.categoryStore = categoryStore
		self.categoryStore.setDelegate(delegateForStore: self)
		self.categories = getCategoriesFromStore()
	}
	
	func selectCategory(category: CategoryElementViewModel) {
		selectedCategory = category
		categories = getCategoriesFromStore()
	}
	
	func categoryListIsEmpty() -> Bool {
		categoryStore.categoryListIsEmpty()
	}
	
	private func getCategoriesFromStore() -> [CategoryElementViewModel] {
		return categoryStore.categories.map {
			let uuidString = $0.categoryID!
			let name = $0.name!
			
			return CategoryElementViewModel(id: uuidString,
											name: name,
											selectedCategory: uuidString == selectedCategory?.id
			)
		}
	}
}

extension CategoryListViewModel: ITrackerCategoryStoreDelegate {
	func categoriesDidUpdate() {
		categories = getCategoriesFromStore()
	}
}
