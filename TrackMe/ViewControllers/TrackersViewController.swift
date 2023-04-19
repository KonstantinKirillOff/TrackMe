//
//  TrackersViewController.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 13.04.2023.
//

import UIKit

final class TrackersViewController: UIViewController {
	
	private var categories = [TrackerCategory(name: "Категория которая была", trackers: [
		Tracker(name: "Кодить",
				color: UIColor(named: "Color\(Int.random(in: 1...6))") ?? .darkGray,
				emoji: "😇",
				schedule: [1, 2, 3, 4, 5])
	])]
	private var visibleForDay = [TrackerCategory]()
	private var visibleCategoriesAfterFilter = [TrackerCategory]()
	
	private var completedTrackers: Set<TrackerRecord> = []
	private var currentDate: Date?
	
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
		datePicker.addTarget(self, action: #selector(showTrackersOnDate), for: .valueChanged)
		return datePicker
	}()
	
	private lazy var collectionView: UICollectionView = {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
		collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderView.identifier)
		collectionView.register(CardTrackerCell.self, forCellWithReuseIdentifier: CardTrackerCell.identifier)
		return collectionView
	}()
	
	private lazy var searchController: UISearchController = {
		let searchController = UISearchController(searchResultsController: nil)
		searchController.obscuresBackgroundDuringPresentation = false
		searchController.searchBar.placeholder = "Поиск"
		return searchController
	}()
	
	private lazy var emptyStub: UIStackView = {
		let image = UIImageView(image: UIImage(named: "EmptyTrackers") ?? UIImage())
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
		currentDate = Date()
		
		setupView()
		setupCollectionView()
		setupNavigationBar()
		setupStubEmpty()
		
		visibleForDay = filterTrackersByDay()
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
		let cardCount = isFiltered ? visibleCategoriesAfterFilter.count : visibleForDay.count
		emptyStub.isHidden = (cardCount > 0)
	}
	
	private func filterTrackersByDay() -> [TrackerCategory] {
		let weekDay = Calendar.current.component(.weekday, from: currentDate!)
		let suitableCategory = categories.filter({ $0.trackers.filter({ $0.schedule.contains(weekDay) }).count > 0 })
		let visibleCategoriesForDay = suitableCategory.map({ category in
			let filteredTrackers = category.trackers.filter({ $0.schedule.contains(weekDay) })
			return TrackerCategory(name: category.name, trackers: filteredTrackers)
		})
		
		return visibleCategoriesForDay
	}
	
	private func getDayWithoutTime(date: Date) -> Date {
		let dateWithoutTime = Calendar.current.dateComponents([.year, .month, .day], from: date)
		return Calendar.current.date(from: dateWithoutTime)!
	}
	
	@objc private func openAddNewTrackerVC() {
		let chooseVC = ChooseTrackerViewController()
		chooseVC.delegate = self
		present(chooseVC, animated: true)
	}
	
	@objc private func showTrackersOnDate() {
		currentDate = datePicker.date
		visibleForDay = filterTrackersByDay()
		collectionView.reloadData()
		checkEmptyTrackers()
	}
}

extension TrackersViewController: UICollectionViewDataSource {
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		isFiltered ? visibleCategoriesAfterFilter.count : visibleForDay.count
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		let trackersCategoriesArray = isFiltered ? visibleCategoriesAfterFilter : visibleForDay
		let category = trackersCategoriesArray[section]
		return category.trackers.count
	}
	
	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		guard kind == UICollectionView.elementKindSectionHeader else { return UICollectionReusableView() }
		
		let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderView.identifier, for: indexPath) as! HeaderView
		let trackersCategoriesArray = isFiltered ? visibleCategoriesAfterFilter : visibleForDay
		let category = trackersCategoriesArray[indexPath.section]
		headerView.headerTittle.text = category.name
		return headerView
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardTrackerCell.identifier, for: indexPath) as! CardTrackerCell
		
		let trackersCategoriesArray = isFiltered ? visibleCategoriesAfterFilter : visibleForDay
		let tracker = trackersCategoriesArray[indexPath.section].trackers[indexPath.row]
		cell.delegate = self
		cell.configCell(for: tracker, record: completedTrackers.filter({ $0.id == tracker.id }).count, tracked: trackerTrackedToday(id: tracker.id))
		return cell
	}
}

extension TrackersViewController: ICardTrackCellDelegate {
	func quantityButtonPressed(_ cell: CardTrackerCell) {
		guard let indexPath = collectionView.indexPath(for: cell) else { return }
		guard currentDate! <= Date() else { return }
		
		let trackersCategoriesArray = isFiltered ? visibleCategoriesAfterFilter : visibleForDay
		let tracker = trackersCategoriesArray[indexPath.section].trackers[indexPath.row]
		
		if !trackerTrackedToday(id: tracker.id) {
			completedTrackers.insert(TrackerRecord(id: tracker.id, date: getDayWithoutTime(date: currentDate!)))
			collectionView.reloadItems(at: [indexPath])
		} else {
			completedTrackers.remove(TrackerRecord(id: tracker.id, date: getDayWithoutTime(date: currentDate!)))
			collectionView.reloadItems(at: [indexPath])
		}
	}
	
	private func trackerTrackedToday(id: UUID) -> Bool {
		let mockTracker = TrackerRecord(id: id, date: getDayWithoutTime(date: currentDate!))
		return completedTrackers.contains(mockTracker)
	}
	
}

extension TrackersViewController: UISearchResultsUpdating {
	func updateSearchResults(for searchController: UISearchController) {
		let searchingString = searchController.searchBar.text!.lowercased()
		let suitCategory = visibleForDay.filter({ $0.trackers.filter({ $0.name.lowercased().contains(searchingString) }).count > 0 })
		visibleCategoriesAfterFilter = suitCategory.map({ category in
			TrackerCategory(name: category.name, trackers: category.trackers.filter({ $0.name.lowercased().contains(searchingString) }))
		})
		collectionView.reloadData()
		checkEmptyTrackers()
	}
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

extension TrackersViewController: IChooseTrackerViewControllerDelegate {
	func newTrackerDidAdd(tracker: Tracker, categoryName: String, vc: ChooseTrackerViewController) {
		vc.dismiss(animated: true) { [weak self] in
			guard let self = self else { return }
			
			if let index = self.categories.firstIndex(where: {$0.name == categoryName}) {
				let oldCategory = self.categories.remove(at: index)
				let updatedCategory = TrackerCategory(name: categoryName, trackers: oldCategory.trackers + [tracker])
				self.categories.insert(updatedCategory, at: index)
			} else {
				let newCategory = TrackerCategory(name: categoryName, trackers: [tracker])
				self.categories.append(newCategory)
			}
			
			self.visibleForDay = filterTrackersByDay()
			self.collectionView.reloadData()
			self.checkEmptyTrackers()
		}
	}
}
