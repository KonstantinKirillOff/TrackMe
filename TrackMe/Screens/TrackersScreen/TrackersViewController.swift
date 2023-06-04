//
//  TrackersViewController.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 13.04.2023.
//

import UIKit

final class TrackersViewController: UIViewController {
	private var dataProvider: IDataProviderProtocol!
	private var currentDate: Date!
	
	private var searchBarIsEmpty: Bool {
		guard let text = searchController.searchBar.text else { return true }
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
		
		do {
			try dataProvider.addFiltersForFetchResultController(searchControllerText: "", currentDay: getDayWithoutTime(date: currentDate))
		} catch {
			//TODO: show alert
			print(error.localizedDescription)
		}
		checkEmptyTrackers()
	}
	
	func initialize(dataProvider: IDataProviderProtocol) {
		self.dataProvider = dataProvider
	}
	
	private func setupView() {
		view.backgroundColor = Colors.backgroundColor
		
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
		let fetchControllerIsEmpty = dataProvider.fetchResultControllerIsEmpty()
		emptyStub.isHidden = !fetchControllerIsEmpty
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
		do {
			try dataProvider.addFiltersForFetchResultController(searchControllerText: isFiltered ? searchController.searchBar.text! : "",
																 currentDay: getDayWithoutTime(date: currentDate))
		} catch {
			//TODO: show alert
			print(error.localizedDescription)
		}
		collectionView.reloadData()
		checkEmptyTrackers()
	}
}

extension TrackersViewController: UICollectionViewDataSource {
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		dataProvider.numberOfSections
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		dataProvider.numberOfRowsInSection(section)
	}
	
	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		guard kind == UICollectionView.elementKindSectionHeader else { return UICollectionReusableView() }
		
		guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
																			   withReuseIdentifier: HeaderView.identifier,
																			   for: indexPath) as? HeaderView else { return UICollectionReusableView() }
		
		let sectionName = dataProvider.nameOfSection(indexPath.section)
		headerView.headerTittle.text = sectionName
		return headerView
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardTrackerCell.identifier, for: indexPath) as? CardTrackerCell else { return UICollectionViewCell()
		}
		guard let tracker = dataProvider.getTrackerObject(at: indexPath) else { return UICollectionViewCell() }
		
		let uuidString = tracker.id.uuidString
		let recordCountForTracker = dataProvider.countRecordForTracker(trackerID: uuidString)
		let trackerTrackedToday = dataProvider.trackerTrackedToday(date: getDayWithoutTime(date: currentDate), trackerID: uuidString)
		
		cell.delegate = self
		cell.configCell(for: tracker, record: recordCountForTracker, tracked: trackerTrackedToday)
		return cell
	}
}

extension TrackersViewController: ICardTrackCellDelegate {
	func quantityButtonPressed(_ cell: CardTrackerCell) {
		guard let indexPath = collectionView.indexPath(for: cell) else { return }
		guard currentDate <= Date() else { return }
		guard let tracker = dataProvider.getTrackerObject(at: indexPath) else { return }
		
		let dateWithoutTime = getDayWithoutTime(date: currentDate)
		let trackerCoreData = dataProvider.getTrackerCoreData(at: indexPath)
		let uuidString = tracker.id.uuidString
		let trackerTrackedToday = dataProvider.trackerTrackedToday(date: dateWithoutTime, trackerID: uuidString)
		
		if !trackerTrackedToday {
			do {
				try dataProvider.addTrackerRecord(TrackerRecord(id: tracker.id, date: dateWithoutTime), for: trackerCoreData)
			} catch {
				//TODO: show alert
				print(error.localizedDescription)
			}
			collectionView.reloadItems(at: [indexPath])
		} else {
			dataProvider.deleteRecord(date: dateWithoutTime, trackerID: uuidString)
			collectionView.reloadItems(at: [indexPath])
		}
	}
}

extension TrackersViewController: UISearchResultsUpdating {
	func updateSearchResults(for searchController: UISearchController) {
		let searchBarText = searchController.searchBar.text ?? ""
		let searchingString = searchBarText.lowercased()
		do {
			try dataProvider.addFiltersForFetchResultController(searchControllerText: searchingString,
																 currentDay: getDayWithoutTime(date: currentDate))
		} catch {
			//TODO: show alert
			print(error.localizedDescription)
		}
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
	func newTrackerDidAdd(tracker: Tracker, selectedCategory: CategoryElementViewModel, vc: ChooseTrackerViewController) {
		vc.dismiss(animated: true) { [weak self] in
			guard let self = self else { return }
			
			//get/add category
			guard let category = self.dataProvider.fetchCategory(by: selectedCategory.id) else {
				return
			}

			//add tracker
			do {
				try self.dataProvider.addTracker(tracker, category: category)
			} catch {
				//TODO: show alert
				print(error.localizedDescription)
			}

			//make filters
			let searchBarText = self.searchController.searchBar.text ?? ""
			do {
				try self.dataProvider.addFiltersForFetchResultController(searchControllerText: self.isFiltered ? searchBarText: "", 													  currentDay: self.getDayWithoutTime(date: self.currentDate))
			} catch {
				//TODO: show alert
				print(error.localizedDescription)
			}
																		 
			self.checkEmptyTrackers()
		}
	}
}

extension TrackersViewController: IDataProviderDelegate {
	func trackersStoreDidUpdate() {
		collectionView.reloadData()
	}
}
