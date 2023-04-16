//
//  TrackersViewController.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 13.04.2023.
//

import UIKit

final class TrackersViewController: UIViewController {
	
	private var categories = [TrackerCategory(name: "Радостные мелочи", trackers: [
		Tracker(name: "Пить воду", color: UIColor(named: "Color3")!, emoji: "🤖", schedule: [1, 3]),
		Tracker(name: "Tracker 2 Разработка на IOS 2 часа в день", color: UIColor(named: "Color6")!, emoji: "😍", schedule: [1, 2, 3, 4, 5])]),
							  TrackerCategory(name: "Домашний уют", trackers: [
		Tracker(name: "Tracker 3 Дыхательные практики", color: UIColor(named: "Color2")!, emoji: "😤", schedule: [1, 2])])
	]
	private var visibleCategories = [TrackerCategory]()
	private var completedTrackers = [TrackerRecord]()
	
	private var searchBarIsEmpty: Bool {
		guard let text = searchController.searchBar.text else { return false }
		return text.isEmpty
	}
	
	private var isFiltered: Bool {
		searchController.isActive && !searchBarIsEmpty
	}
	
	private lazy var datePicker: UIDatePicker = {
		let datePicker = UIDatePicker()
		datePicker.preferredDatePickerStyle = .compact
		datePicker.datePickerMode = .date
		datePicker.addTarget(self, action: #selector(showTrackersOnDate), for: .editingDidEnd)
		return datePicker
	}()
	
	private let collectionView: UICollectionView = {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
		collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderView.identifier)
		collectionView.register(CardTrackerCell.self, forCellWithReuseIdentifier: CardTrackerCell.identifier)
		return collectionView
	}()
	
	private let searchController: UISearchController = {
		let searchController = UISearchController(searchResultsController: nil)
		searchController.obscuresBackgroundDuringPresentation = false
		searchController.searchBar.placeholder = "Поиск"
		return searchController
	}()
	
	private let emptyStub: UIStackView = {
		let image = UIImageView(image: UIImage(named: "EmptyTrackers")!)
		let titleLabel = UILabel()
		titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
		titleLabel.text = "Что будем отслеживать?"
		
		let stackView = UIStackView()
		stackView.axis = .vertical
		stackView.alignment = .center
		stackView.distribution = .equalSpacing
		stackView.spacing = 10
		stackView.addArrangedSubview(image)
		stackView.addArrangedSubview(titleLabel)
		
		return stackView
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupView()
		setupCollectionView()
		setupNavigationBar()
		setupStubEmpty()
		checkEmptyTrackers()
	}
	
	private func setupView() {
		view.backgroundColor = .white
		
		if let navBar = navigationController?.navigationBar {
			title = "Трэкеры"
			navBar.prefersLargeTitles = true
			  
			let leftButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(openAddNewTrackerVC))
			leftButton.tintColor = .label
			navigationItem.leftBarButtonItem = leftButton
			
			let rightItem = UIBarButtonItem(customView: datePicker)
			navigationItem.rightBarButtonItem = rightItem
		}
	}
	
	private func setupCollectionView() {
		view.addSubview(collectionView)
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
			collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
		])
		
		collectionView.dataSource = self
		collectionView.delegate = self
	}
	
	private func setupNavigationBar() {
		searchController.searchResultsUpdater = self
		definesPresentationContext = true
		navigationItem.searchController = searchController
	}
	
	private func setupStubEmpty() {
		view.addSubview(emptyStub)
		emptyStub.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			emptyStub.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor),
			emptyStub.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor)
		])
	}
	
	private func checkEmptyTrackers() {
		let cardCount = isFiltered ? visibleCategories.count : categories.count
		emptyStub.isHidden = (cardCount > 0)
	}
	
	@objc private func openAddNewTrackerVC() {
		print("addTrackerVC")
	}
	
	@objc private func showTrackersOnDate() {
		let newDate = datePicker.date
		print("\(newDate)")
	}
}

extension TrackersViewController: UICollectionViewDataSource {
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		isFiltered ? visibleCategories.count : categories.count
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		let trackersCategoriesArray = isFiltered ? visibleCategories : categories
		let category = trackersCategoriesArray[section]
		return category.trackers.count
	}
	
	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		guard kind == UICollectionView.elementKindSectionHeader else { return UICollectionReusableView() }
		
		let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderView.identifier, for: indexPath) as! HeaderView
		let trackersCategoriesArray = isFiltered ? visibleCategories : categories
		let category = trackersCategoriesArray[indexPath.section]
		headerView.headerTittle.text = category.name
		return headerView
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardTrackerCell.identifier, for: indexPath) as! CardTrackerCell
		
		let trackersCategoriesArray = isFiltered ? visibleCategories : categories
		let tracker = trackersCategoriesArray[indexPath.section].trackers[indexPath.row]
		cell.configCell(for: tracker)
		return cell
	}
}

extension TrackersViewController: UISearchResultsUpdating {
	func updateSearchResults(for searchController: UISearchController) {
		let searchingString = searchController.searchBar.text!.lowercased()
		let suitCategory = categories.filter({ $0.trackers.filter({ $0.name.lowercased().contains(searchingString) }).count > 0 })
		visibleCategories = suitCategory.map({ category in
			TrackerCategory(name: category.name, trackers: category.trackers.filter({ $0.name.lowercased().contains(searchingString) }))
		})
		collectionView.reloadData()
		checkEmptyTrackers()
	}
}

extension TrackersViewController: UICollectionViewDelegate {
	
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		CGSize(width: (collectionView.bounds.width - 41)/2, height: 148)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		9
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		0
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		UIEdgeInsets(top: 34, left: 16, bottom: 0, right: 16)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
		let indexPath = IndexPath(row: 0, section: section)
		let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
		
		return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width,
														 height: UIView.layoutFittingExpandedSize.height),
														 withHorizontalFittingPriority: .required,
														 verticalFittingPriority: .fittingSizeLevel)
	}
}
