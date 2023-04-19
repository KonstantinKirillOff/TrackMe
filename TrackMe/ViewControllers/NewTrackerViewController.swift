//
//  NewTrackerViewController.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 17.04.2023.
//

import UIKit

protocol INewTrackerViewControllerDelegate: AnyObject {
	func newTrackerDidAdd(tracker: Tracker, categoryName: String, vc: NewTrackerViewController)
}

final class NewTrackerViewController: UIViewController {
	private var trackerTypes = [String]()
	private var headerForView = ""
	
	private var weekSchedule: [Int : WeekDay] = [:]
	private var categoryName = "Домашний уют"
	
	weak var delegate: INewTrackerViewControllerDelegate?
	
	private lazy var headerLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 16)
		label.textAlignment = .center
		return label
	}()
	
	private lazy var nameTrackerTextField: UITextField = {
		let textField = UITextField()
		textField.placeholder  = "    Введите название трэкера"
		textField.font = UIFont.systemFont(ofSize: 17)
		textField.backgroundColor = UIColor(named: "YPBackground")
		textField.layer.cornerRadius = 16
		return textField
	}()
	
	private lazy var tableView: UITableView = {
		let tableView = UITableView()
		tableView.rowHeight = 75
		tableView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
		tableView.layer.masksToBounds = true
		tableView.layer.cornerRadius = 16
		tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
		return tableView
	}()
	
	private lazy var cancelButton: UIButton = {
		let button = UIButton()
		button.setTitle("Отменить", for: .normal)
		button.layer.cornerRadius = 16
		button.layer.borderWidth = 1
		button.layer.borderColor = UIColor(named: "YPRed")?.cgColor
		button.backgroundColor = UIColor(named: "YPWhite")
		button.setTitleColor(UIColor(named: "YPRed"), for: .normal)
		button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
		button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
		return button
	}()
	
	private lazy var addButton: UIButton = {
		let button = UIButton()
		button.setTitle("Создать", for: .normal)
		button.backgroundColor = UIColor(named: "YPBlack")
		button.setTitleColor(UIColor(named: "YPWhite"), for: .normal)
		button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
		button.layer.cornerRadius = 16
		button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
		return button
	}()
	
	private lazy var buttonsStackView: UIStackView = {
		let stackView = UIStackView()
		stackView.axis = .horizontal
		stackView.alignment = .fill
		stackView.distribution = .fillEqually
		stackView.spacing = 8
		stackView.addArrangedSubview(cancelButton)
		stackView.addArrangedSubview(addButton)
		return stackView
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		
		setupUIElements()
		setupTableView()
	}
	
	private func setupTableView() {
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "tableViewCell")
		tableView.delegate = self
		tableView.dataSource = self
		
		view.addSubview(tableView)
		tableView.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
			tableView.topAnchor.constraint(equalTo: nameTrackerTextField.bottomAnchor, constant: 24),
			tableView.heightAnchor.constraint(equalToConstant: CGFloat(trackerTypes.count * 75))
		])
	}
	
	private func setupUIElements() {
		headerLabel.text = headerForView
		view.addSubview(headerLabel)
		headerLabel.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
			headerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
			headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27)
		])
		
		view.addSubview(nameTrackerTextField)
		nameTrackerTextField.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			nameTrackerTextField.heightAnchor.constraint(equalToConstant: 75),
			nameTrackerTextField.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 38),
			nameTrackerTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			nameTrackerTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
		])
		
		
		view.addSubview(buttonsStackView)
		buttonsStackView.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			buttonsStackView.heightAnchor.constraint(equalToConstant: 60),
			buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
			buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
			buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
		])
	}
	
	private func getScheduleInString() -> String {
		return weekSchedule.sorted(by: { $0.key < $1.key }).map({ $0.value.rawValue }).joined(separator: ", ")
	}

	private func getNumberDay(for weekDay: WeekDay) -> Int {
		switch weekDay {
		case .Понедельник:
			return 2
		case .Вторник:
			return 3
		case .Среда:
			return 4
		case .Четверг:
			return 5
		case .Пятница:
			return 6
		case .Суббота:
			return 7
		case .Воскресенье:
			return 1
		}
	}
	
	@objc private func cancelButtonTapped() {
		dismiss(animated: true)
	}
	
	@objc private func addButtonTapped() {
		var trackName = "No name tracker"
		if let text = nameTrackerTextField.text, !text.isEmpty {
			trackName = text
		}
		
		let currentDayWeek = Calendar.current.component(.weekday, from: Date())
		let setWithWeekDays = weekSchedule.isEmpty ? Set([currentDayWeek]) : Set(weekSchedule.map({$0.key}))
		let newTracker = Tracker(name: trackName,
								 color: UIColor(named: "Color\(Int.random(in: 1...6))") ?? .darkGray,
								 emoji: "🤖",
								 schedule: setWithWeekDays)
	
		delegate?.newTrackerDidAdd(tracker: newTracker, categoryName: categoryName, vc: self)
		dismiss(animated: true)
	}
	
	func configViewController(header: String, trackerTypes: [String], delegate: INewTrackerViewControllerDelegate) {
		self.trackerTypes = trackerTypes
		self.headerForView = header
		self.delegate = delegate
	}
}

extension NewTrackerViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		trackerTypes.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = UITableViewCell(style: .subtitle, reuseIdentifier: ScheduleCell.identifier)

		cell.textLabel?.text = trackerTypes[indexPath.row]
		
		cell.detailTextLabel?.textColor = UIColor(named: "YPGray")
		cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 17)
		
		//category
		if indexPath.row == 0 {
			cell.detailTextLabel?.text = categoryName
		} else { //weekSchedule
			let weekSchedule = getScheduleInString()
			cell.detailTextLabel?.text = weekSchedule
		}
		
		cell.selectionStyle = .none
		cell.accessoryType = .disclosureIndicator
		cell.backgroundColor = UIColor(named: "YPBackground")
		return cell
	}
}

extension NewTrackerViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.row == 1 {
			let scheduleVC = ScheduleViewController()
			scheduleVC.delegate = self
			present(scheduleVC, animated: true)
		}
	}
}

extension NewTrackerViewController: IScheduleControllerDelegate {
	func getScheduleForTracker(weekDays: Set<WeekDay>) {
		weekDays.forEach { weekSchedule[getNumberDay(for: $0)] = $0 }
		tableView.reloadData()
	}
}
