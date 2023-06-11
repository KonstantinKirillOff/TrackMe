//
//  EditTrackerVC.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 06.06.2023.
//

import UIKit

protocol IEditTrackerViewControllerDelegate: AnyObject {
	func trackerDidEdit(tracker: Tracker, selectedCategory: CategoryElementViewModel, vc: EditTrackerViewController)
}

final class EditTrackerViewController: UIViewController{
	private let trackerForEdit: Tracker!
	private var selectedCategory: CategoryElementViewModel?
	private var selectedDay: Date
	
	private let colors = (1...18).map { UIColor(named: "Color\($0)") ?? .darkGray }
	private let emojies = ["🙂", "😻", "🌺", "🐶", "❤️", "😱",
						   "😇", "😡", "🥶", "🤔", "🙌", "🍔",
						   "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
	
	private var currentColor: UIColor!
	private var currentEmoji: String!
	
	private var trackerTypes = [String]()
	private var headerForView = ""
	private var weekSchedule: [String : WeekDay] = [:]
	
	
	weak var delegate: IEditTrackerViewControllerDelegate?
	
	private lazy var headerLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 16)
		label.textAlignment = .center
		return label
	}()
	
	private lazy var editCountDaysView: EditCountDaysView = {
		let view = EditCountDaysView()
		view.delegate = self
		return view
	}()
	
	private lazy var nameTrackerTextField: UITextField = {
		let textField = BaseTextField()
		textField.placeholder  = "Введите название трэкера"
		return textField
	}()
	
	private lazy var tableView: UITableView = {
		let tableView = UITableView()
		tableView.rowHeight = 75
		tableView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
		tableView.layer.masksToBounds = true
		tableView.layer.cornerRadius = 16
		tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "tableViewCell")
		return tableView
	}()
	
	private lazy var emojiLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
		label.textAlignment = .left
		label.text = "Emoji"
		return label
	}()
	
	private lazy var emojiCollectionView: UICollectionView = {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
		collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.identifier)
		return collectionView
	}()
	
	private lazy var colorLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
		label.textAlignment = .left
		label.text = "Цвет"
		return label
	}()
	
	private lazy var colorCollectionView: UICollectionView = {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
		collectionView.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.identifier)
		return collectionView
	}()
	
	private lazy var cancelButton: UIButton = {
		let button = UIButton()
		button.setTitle("Отменить", for: .normal)
		button.layer.cornerRadius = 16
		button.layer.borderWidth = 1
		button.layer.borderColor = Colors.ypRed?.cgColor
		button.backgroundColor = Colors.ypWhite
		button.setTitleColor(Colors.ypRed, for: .normal)
		button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
		button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
		return button
	}()
	
	private lazy var addButton: UIButton = {
		let button = UIButton()
		button.setTitle("Сохранить", for: .normal)
		button.backgroundColor = Colors.ypBlack
		button.setTitleColor(Colors.ypWhite, for: .normal)
		button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
		button.layer.cornerRadius = 16
		button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
		return button
	}()
	
	private lazy var buttonsHorizontalStackView: UIStackView = {
		let stackView = UIStackView()
		stackView.axis = .horizontal
		stackView.alignment = .fill
		stackView.distribution = .fillEqually
		stackView.spacing = 8
		stackView.addArrangedSubview(cancelButton)
		stackView.addArrangedSubview(addButton)
		return stackView
	}()
	
	private lazy var scrollView: UIScrollView = {
		let scrollView = UIScrollView()
		scrollView.alwaysBounceVertical = true
		return scrollView
	}()
	
	private lazy var contentView: UIView = {
		let contentView = UIView()
		return contentView
	}()
	
	init(tracker: Tracker, selectedDay: Date) {
		self.trackerForEdit = tracker
		self.selectedDay = selectedDay
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = Colors.backgroundColor
		
		setupUIElements()
		setUpScrollView()
		setupTextField()
		setupTableView()
		setupEmojiCollectionView()
		setupColorCollectionView()
	}
	
	func configViewController(header: String,
							  trackerTypes: [String],
							  delegate: IEditTrackerViewControllerDelegate,
							  selectedCategory: CategoryElementViewModel) {
		
		self.trackerTypes = trackerTypes
		self.headerForView = header
		self.delegate = delegate
		
		self.selectedCategory = selectedCategory
		self.currentColor = trackerForEdit.color
		self.currentEmoji = trackerForEdit.emoji
		self.nameTrackerTextField.text = trackerForEdit.name
	}
	
	private func setupUIElements() {
		headerLabel.text = headerForView
		view.addSubview(headerLabel)
		headerLabel.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			headerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
			headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27)
		])
		
		view.addSubview(buttonsHorizontalStackView)
		buttonsHorizontalStackView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			buttonsHorizontalStackView.heightAnchor.constraint(equalToConstant: 60),
			buttonsHorizontalStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
			buttonsHorizontalStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
			buttonsHorizontalStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
		])
	}
	
	private func setUpScrollView() {
		view.addSubview(scrollView)
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			scrollView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 14),
			scrollView.bottomAnchor.constraint(equalTo: buttonsHorizontalStackView.topAnchor)
		])
		
		scrollView.addSubview(contentView)
		contentView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
			contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
			contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
			contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
			contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
			contentView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height - 100)
		])
	}
	
	private func setupTextField() {
		editCountDaysView.config(countDay: 2,
								 isChecked: true,
								 canCheck: true)
		contentView.addSubview(editCountDaysView)
		editCountDaysView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			editCountDaysView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
			editCountDaysView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
		])
		
		contentView.addSubview(nameTrackerTextField)
		nameTrackerTextField.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			nameTrackerTextField.heightAnchor.constraint(equalToConstant: 75),
			nameTrackerTextField.topAnchor.constraint(equalTo: editCountDaysView.bottomAnchor, constant: 40),
			nameTrackerTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			nameTrackerTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
		])
	}
	
	private func setupTableView() {
		tableView.delegate = self
		tableView.dataSource = self
		
		contentView.addSubview(tableView)
		tableView.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			tableView.topAnchor.constraint(equalTo: nameTrackerTextField.bottomAnchor, constant: 24),
			tableView.heightAnchor.constraint(equalToConstant: CGFloat(trackerTypes.count * 75))
		])
	}
	
	private func setupEmojiCollectionView() {
		emojiCollectionView.delegate = self
		emojiCollectionView.dataSource = self
		emojiCollectionView.allowsMultipleSelection = false
		
		contentView.addSubview(emojiLabel)
		emojiLabel.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			emojiLabel.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
			emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
			emojiLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 28)
		])
		
		contentView.addSubview(emojiCollectionView)
		emojiCollectionView.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			emojiCollectionView.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor),
			emojiCollectionView.heightAnchor.constraint(equalToConstant: 204),
		])
	}
	
	private func setupColorCollectionView() {
		colorCollectionView.delegate = self
		colorCollectionView.dataSource = self
		colorCollectionView.allowsMultipleSelection = false
		
		contentView.addSubview(colorLabel)
		colorLabel.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			colorLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor),
			colorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
			colorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 28)
		])
		
		contentView.addSubview(colorCollectionView)
		colorCollectionView.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			colorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			colorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
			colorCollectionView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor),
			colorCollectionView.heightAnchor.constraint(equalToConstant: 204),
		])
	}
	
	private func getScheduleInString() -> String {
		return weekSchedule.sorted(by: { $0.key < $1.key }).map({ $0.value.rawValue }).joined(separator: ", ")
	}
	
	@objc private func cancelButtonTapped() {
		dismiss(animated: true)
	}
	
	@objc private func addButtonTapped() {
		guard let category = selectedCategory else {
			assertionFailure("category not set!")
			//TODO: show alert
			return
		}
		
		var trackName = "No name tracker"
		if let text = nameTrackerTextField.text, !text.isEmpty {
			trackName = text
		}
		
		let currentDayWeek = String(Calendar.current.component(.weekday, from: Date()))
		let setWithWeekDays = weekSchedule.isEmpty ? Set([currentDayWeek]) : Set(weekSchedule.map({$0.key}))
		let newTrackerData = Tracker(id: UUID(),
								 name: trackName,
								 color: currentColor,
								 emoji: currentEmoji,
								 schedule: setWithWeekDays,
								 isHabit: trackerTypes.count > 1 ? true : false,
								 idCategoryBeforePin: category.id,
								 isPinned: trackerForEdit.isPinned)
	
		delegate?.trackerDidEdit(tracker: newTrackerData, selectedCategory: category, vc: self)
		dismiss(animated: true)
	}
}

extension EditTrackerViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		trackerTypes.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell(style: .subtitle, reuseIdentifier: ScheduleCell.identifier)

		cell.textLabel?.text = trackerTypes[indexPath.row]
		
		cell.detailTextLabel?.textColor = Colors.ypGray
		cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 17)
		
		//category
		if indexPath.row == 0 {
			cell.detailTextLabel?.text = selectedCategory?.name
		} else { //weekSchedule
			let weekSchedule = getScheduleInString()
			cell.detailTextLabel?.text = weekSchedule
		}
		
		cell.selectionStyle = .none
		cell.accessoryType = .disclosureIndicator
		cell.backgroundColor = Colors.ypBackground
		return cell
	}
}

extension EditTrackerViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.row == 1 {
			let scheduleVC = ScheduleViewController()
			scheduleVC.delegate = self
			present(scheduleVC, animated: true)
		} else {
			let categoryListVM = CategoryListViewModel(categoryStore: TrackerCategoryStore())
			let categoryListVC = CategoryListViewController()
			categoryListVC.delegate = self
			categoryListVC.initialise(viewModel: categoryListVM)
			present(categoryListVC, animated: true)
		}
	}
}

extension EditTrackerViewController: IScheduleControllerDelegate {
	func getScheduleForTracker(weekDays: Set<WeekDay>) {
		weekDays.forEach { weekSchedule[$0.getNumberDay()] = $0 }
		tableView.reloadData()
	}
}

extension EditTrackerViewController: ICategoryListViewControllerDelegate {
	func categoryDidSelected(category: CategoryElementViewModel, vc: CategoryListViewController) {
		vc.dismiss(animated: true) { [weak self] in
			guard let self = self else { return }
			self.selectedCategory = category
			tableView.reloadData()
		}
	}
}

extension EditTrackerViewController: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		collectionView == emojiCollectionView ? emojies.count : colors.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if collectionView == emojiCollectionView {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCell.identifier, for: indexPath) as! EmojiCell
			cell.configCell(for: emojies[indexPath.row], isSelected: emojies[indexPath.row] == currentEmoji)
			return cell
		} else {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.identifier, for: indexPath) as! ColorCell
			cell.configCell(for: colors[indexPath.row], isSelected: colors[indexPath.row].toHexString == currentColor.toHexString)
			return cell
		}
	}
}

extension EditTrackerViewController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if collectionView == emojiCollectionView {
			let emoji = emojies[indexPath.row]
			let cell = collectionView.cellForItem(at: indexPath) as? EmojiCell
			cell?.configCell(for: emoji, isSelected: true)
			currentEmoji = emoji
		} else {
			let color = colors[indexPath.row]
			let cell = collectionView.cellForItem(at: indexPath) as? ColorCell
			cell?.configCell(for: color, isSelected: true)
			currentColor = color
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
		if collectionView == emojiCollectionView {
			let cell = collectionView.cellForItem(at: indexPath) as? EmojiCell
			cell?.configCell(for: emojies[indexPath.row], isSelected: false)
		} else {
			let cell = collectionView.cellForItem(at: indexPath) as? ColorCell
			cell?.configCell(for: colors[indexPath.row], isSelected: false)
		}
	}
}

extension EditTrackerViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		CGSize(width: 52, height: 52)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		5
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		0
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		UIEdgeInsets(top: 24, left: 18, bottom: 24, right: 18)
	}
}

extension EditTrackerViewController: EditCountDaysViewDelegate {
	func checkDay() {
		//TODO: changeRecord
	}
	
	func uncheckDay() {
		//TODO: changeRecord
	}
}

