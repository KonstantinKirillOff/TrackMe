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
	private let analyticService = AnalyticServiceManager.shared
	private let settingsManager = SettingsManager.shared
	private var selectedFilter: FilterType = .trackersForToday
	
	private var searchBarIsEmpty: Bool {
		guard let text = searchController.searchBar.text else { return true }
		return text.isEmpty
	}
	
	private var isFiltered: Bool {
		searchController.isActive && !searchBarIsEmpty
	}
	
	private var searchText: String {
		let searchBarText = searchController.searchBar.text ?? ""
		return isFiltered ? searchBarText: ""
	}
	
	private lazy var datePicker: UIDatePicker = {
		let datePicker = UIDatePicker()
		datePicker.datePickerMode = .date
		datePicker.preferredDatePickerStyle = .compact
		datePicker.locale = .current
		datePicker.calendar = Calendar(identifier: .iso8601)
		datePicker.addTarget(self, action: #selector(showTrackersOnDate), for: .valueChanged)
		return datePicker
	}()
	
	private lazy var collectionView: UICollectionView = {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
		collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderView.identifier)
		collectionView.register(CardTrackerCell.self, forCellWithReuseIdentifier: CardTrackerCell.identifier)
		collectionView.translatesAutoresizingMaskIntoConstraints = false
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
		stackView.translatesAutoresizingMaskIntoConstraints = false
		return stackView
	}()
	
	private lazy var filterButton: UIButton = {
		let buttonTitle = NSLocalizedString("filterTitle", comment: "Title for filter button")
		let button = UIButton()
		button.setTitle(buttonTitle, for: .normal)
		button.backgroundColor = Colors.ypBlue
		button.setTitleColor(Colors.ypWhite, for: .normal)
		button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
		button.layer.cornerRadius = 16
		button.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		currentDate = Date()
		
		setupView()
		setupCollectionView()
		setupNavigationBar()
		setUIElements()
		setupStubEmpty()
		
		loadTrackers(searchString: "",
					 currentDay: currentDate,
					 filtersForTrackerList: selectedFilter)
		
		checkEmptyTrackers()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		analyticService.sendEvent(event: "open", parameters: ["screen" : "main"])
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		analyticService.sendEvent(event: "close", parameters: ["screen" : "main"])
	}
	
	func initialize(dataProvider: IDataProviderProtocol) {
		self.dataProvider = dataProvider
	}
	
	private func setupView() {
		view.backgroundColor = Colors.backgroundColor
		if let navBar = navigationController?.navigationBar {
			title = NSLocalizedString("tabBarItemTracker", comment: "Text displayed on tapBat for trackers screen")
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
		NSLayoutConstraint.activate([
			collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
			collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
		])
		
		collectionView.dataSource = self
		collectionView.delegate = self
	}
	
	private func setUIElements() {
		view.addSubview(filterButton)
		NSLayoutConstraint.activate([
			filterButton.widthAnchor.constraint(equalToConstant: 114),
			filterButton.heightAnchor.constraint(equalToConstant: 50),
			filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
			filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
		])
	}
	
	private func setupNavigationBar() {
		searchController.searchResultsUpdater = self
		definesPresentationContext = true
		navigationItem.searchController = searchController
	}
	
	private func setupStubEmpty() {
		view.addSubview(emptyStub)
		NSLayoutConstraint.activate([
			emptyStub.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor),
			emptyStub.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor)
		])
	}
	
	private func checkEmptyTrackers() {
		let fetchControllerIsEmpty = dataProvider.fetchResultControllerIsEmpty()
		emptyStub.isHidden = !fetchControllerIsEmpty
	}
	
	@objc private func openAddNewTrackerVC() {
		analyticService.sendEvent(event: "click", parameters: ["screen" : "main", "item" : "add_tracker"])
		
		let chooseVC = ChooseTrackerViewController()
		chooseVC.delegate = self
		present(chooseVC, animated: true)
	}
	
	@objc private func showTrackersOnDate() {
		currentDate = datePicker.date
		loadTrackers(searchString: searchText,
					 currentDay: currentDate,
					 filtersForTrackerList: selectedFilter)
		collectionView.reloadData()
		checkEmptyTrackers()
	}
	
	@objc
	private func filterButtonTapped() {
		filterButton.showAnimation { [weak self] in
			guard let self else { return }
			self.showFilterViewController()
		}
	}
	
	private func showFilterViewController() {
		let filterProvider = FilterCollectionViewProvider()
		filterProvider.delegate = self
		let viewController = FiltersViewController(selectedFilter: selectedFilter, provider: filterProvider)
		present(viewController, animated: true)
	}
	
	private func editTracker(tracker: Tracker) {
		guard let currentIdCategory = tracker.idCategoryBeforePin,
		let currentCategory = dataProvider.fetchCategory(by: currentIdCategory) else { return }
		
		let categoryVM = CategoryElementViewModel(id: currentCategory.categoryID ?? "",
												  name: currentCategory.name ?? "",
												  selectedCategory: true)
		
		let editTrackerVC = EditTrackerViewController(tracker: tracker, selectedDay: currentDate)
		let trackerTypes = tracker.isHabit ? ["Категория", "Расписание"] : ["Категория"]
		editTrackerVC.configViewController(header: trackerTypes.count > 1 ? "Редактирование привычки" : "Редактирование не регулярного события",
										   trackerTypes: trackerTypes,
										   delegate: self,
										   selectedCategory: categoryVM)
		present(editTrackerVC, animated: true)
	}
	
	private func showActionSheetForDeleteTracker(indexPath: IndexPath) {
		guard let tracker = dataProvider.getTrackerObject(at: indexPath) else { return }
		
		var deleteActionSheet: UIAlertController {
			let message = NSLocalizedString("deleteActionSheetMessage", comment: "Text for action sheep title")
			let alertController = UIAlertController(title: nil,
													message: message,
													preferredStyle: .actionSheet)
			
			let deleteAction = UIAlertAction(title: NSLocalizedString("deleteActionTitle", comment: "Text for action sheep delete button"),
											 style: .destructive) { [weak self] _ in
				guard let self = self else { return }
				do {
					try self.dataProvider.deleteTracker(by: tracker.id.uuidString)
					self.collectionView.reloadData()
					self.checkEmptyTrackers()
				} catch {
					assertionFailure("Error delete tracker")
				}
			}
			let cancelAction = UIAlertAction(title: NSLocalizedString("cancelActionSheetButtonTitle", comment: "Text for action sheep cancel button"), 							 style: .cancel)
			alertController.addAction(deleteAction)
			alertController.addAction(cancelAction)
			return alertController
		}
		
		let viewController = deleteActionSheet
		present(viewController, animated: true)
	}
	
	private func changePinStatusForTracker(tracker: Tracker, pinStatus: PinStatus) {
		try? dataProvider.changePinStatusForTracker(tracker: tracker, pinStatus: pinStatus)
		collectionView.reloadData()
	}
	
	private func loadTrackers(searchString: String, currentDay: Date, filtersForTrackerList: FilterType) {
		do {
			try dataProvider.addFiltersForFetchResultController(searchControllerText: searchString,
																currentDay: currentDay.getDayWithoutTime(),
																filtersForTrackerList: filtersForTrackerList)
		} catch {
			//TODO: show alert
			print(error.localizedDescription)
		}
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
		let trackerTrackedToday = dataProvider.trackerTrackedToday(date: currentDate.getDayWithoutTime(), trackerID: uuidString)
		
		cell.delegate = self
		cell.configCell(for: tracker, record: recordCountForTracker, tracked: trackerTrackedToday)
		cell.interaction = UIContextMenuInteraction( delegate: self )
		return cell
	}
}

extension TrackersViewController: ICardTrackCellDelegate {
	func quantityButtonPressed(_ cell: CardTrackerCell) {
		analyticService.sendEvent(event: "click", parameters: ["screen" : "main", "item" : "track"])
		
		guard let indexPath = collectionView.indexPath(for: cell) else { return }
		guard currentDate <= Date() else { return }
		guard let tracker = dataProvider.getTrackerObject(at: indexPath) else { return }
		
		let dateWithoutTime = currentDate.getDayWithoutTime()
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
//		let searchBarText = searchController.searchBar.text ?? ""
//		let searchingString = searchBarText.lowercased()
		loadTrackers(searchString: searchText,
					 currentDay: currentDate,
					 filtersForTrackerList: selectedFilter)
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
			
			//get category
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
			loadTrackers(searchString: self.searchText,
						 currentDay: self.currentDate,
						 filtersForTrackerList: self.selectedFilter)
			self.checkEmptyTrackers()
		}
	}
}

extension TrackersViewController: IEditTrackerViewControllerDelegate {
	func trackerDidEdit(tracker: Tracker, selectedCategory: CategoryElementViewModel, vc: EditTrackerViewController) {
		vc.dismiss(animated: true) { [weak self] in
			guard let self = self else { return }
			
			//get category
			var category: TrackerCategoryCoreData?
			if !tracker.isPinned {
				category = self.dataProvider.fetchCategory(by: selectedCategory.id)
			} else {
				category = self.dataProvider.fetchCategory(by: settingsManager.pinnedCategoryId)
			}
			guard let category = category else { return }

			//add tracker
			do {
				try self.dataProvider.changeTracker(tracker: tracker, category: category)
			} catch {
				//TODO: show alert
				print(error.localizedDescription)
			}

			//make filters
			loadTrackers(searchString: self.searchText,
						 currentDay: self.currentDate,
						 filtersForTrackerList: self.selectedFilter)
			self.checkEmptyTrackers()
		}
	}
}

extension TrackersViewController: IDataProviderDelegate {
	func trackersStoreDidUpdate() {
		collectionView.reloadData()
		checkEmptyTrackers()
	}
}

extension TrackersViewController: FilterCollectionViewProviderDelegate {
	func getTrackerWithFilter(_ newFilter: FilterType) {
		selectedFilter = newFilter
		loadTrackers(searchString: searchText,
					 currentDay: currentDate,
					 filtersForTrackerList: selectedFilter)
		dismiss(animated: true)
	}
}

extension TrackersViewController: UIContextMenuInteractionDelegate {
	func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
		
		guard let location = interaction.view?.convert(location, to: collectionView),
			  let indexPath = collectionView.indexPathForItem(at: location),
			  let tracker =  dataProvider.getTrackerObject(at: indexPath)
		else { return UIContextMenuConfiguration() }
		
		return UIContextMenuConfiguration(actionProvider: { [weak self] actions in
			guard let self else { return UIMenu() }
			
			var pinActionTitle: String
			
			if tracker.isPinned {
				pinActionTitle = NSLocalizedString("toUnpinTracker", comment: "")
			} else {
				pinActionTitle = NSLocalizedString("toPinTracker", comment: "")
			}
			
			return UIMenu(children: [
				UIAction(title: pinActionTitle) {  [weak self] _ in
					guard let self else { return }
					let newPinStatus: PinStatus = tracker.isPinned ? .unpinned : .pinned
					self.changePinStatusForTracker(tracker: tracker, pinStatus: newPinStatus)
				},
				UIAction(title:  NSLocalizedString("editActionTitle", comment: "Edit title for UIContext menu")) { [weak self] _ in
					guard let self else { return }
					self.editTracker(tracker: tracker)
				},
				UIAction(
					title: NSLocalizedString("deleteActionTitle", comment: "Text for action sheep delete button"),
					attributes: .destructive,
					handler: { [weak self] _ in
						guard let self else { return }
						self.showActionSheetForDeleteTracker(indexPath: indexPath)
					} )
			])
		})
	}
}
