//
//  NewTrackerViewController.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 17.04.2023.
//

import UIKit

final class NewTrackerViewController: UIViewController {
	private var trackerTypes = [String]()
	private var headerForView = ""
	private var chosenCategory = TrackerCategory(name: "Интересное", trackers: [Tracker]())
	private var weekSchedule = [Int]()
	
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
		tableView.layer.cornerRadius = 16
		tableView.rowHeight = 75
		return tableView
	}()
	
	private lazy var cancelButton: UIButton = {
		let button = UIButton()
		button.setTitle("Отменить", for: .normal)
		button.layer.cornerRadius = 16
		button.layer.borderWidth = 1
		button.layer.borderColor = UIColor(named: "YPRed")?.cgColor
		button.backgroundColor = UIColor(named: "YPWhite")
		button.tintColor = UIColor(named: "YPRed")
		button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
		return button
	}()
	
	private lazy var addButton: UIButton = {
		let button = UIButton()
		button.setTitle("Создать", for: .normal)
		button.backgroundColor = UIColor(named: "YPBlack")
		button.tintColor = UIColor(named: "YPWhite")
		button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
		button.layer.cornerRadius = 16
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
			tableView.heightAnchor.constraint(equalToConstant: 150)
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
	
	func configViewController(header: String, trackerTypes: [String]) {
		self.trackerTypes = trackerTypes
		self.headerForView = header
	}
}

extension NewTrackerViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		trackerTypes.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath)
		
		cell.textLabel?.text = trackerTypes[indexPath.row]
		cell.accessoryType = .disclosureIndicator
		cell.backgroundColor = UIColor(named: "YPBackground")
		return cell
	}
}

extension NewTrackerViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let scheduleVC = ScheduleViewController()
		present(scheduleVC, animated: true)
	}
}
