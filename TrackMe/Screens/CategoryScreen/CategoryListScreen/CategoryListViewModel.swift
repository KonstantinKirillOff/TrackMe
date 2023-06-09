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
	
	func deleteCategory(by id: String) throws {
		do {
			try categoryStore.deleteCategory(by: id)
		} catch {
			throw StoreErrors.deleteElementError
		}
	}
	
	func changeCategory(by id: String, trackerCategory: CategoryElementViewModel) throws {
		do {
			try categoryStore.changeCategory(by: id, trackerCategory: trackerCategory)
		} catch {
			throw StoreErrors.changeElementError
		}
	}
	
	private func getCategoriesFromStore() -> [CategoryElementViewModel] {
		return categoryStore.categories.compactMap {
			guard let uuidString = $0.categoryID,
				  let name = $0.name else { return nil }
			
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
