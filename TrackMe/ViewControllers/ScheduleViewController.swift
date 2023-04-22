//
//  ScheduleViewController.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 17.04.2023.
//

import UIKit

protocol IScheduleControllerDelegate: AnyObject {
	func getScheduleForTracker(weekDays: Set<WeekDay>)
}

final class ScheduleViewController: UIViewController, UITableViewDelegate {
	
	private var daysForSchedule: Set<WeekDay> = []
	weak var delegate: IScheduleControllerDelegate?
	
	private lazy var headerLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 16)
		label.textAlignment = .center
		label.text = "Расписание"
		return label
	}()
	
	private lazy var tableView: UITableView = {
		let tableView = UITableView()
		tableView.rowHeight = 75
		tableView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
		tableView.layer.masksToBounds = true
		tableView.layer.cornerRadius = 16
		tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
		tableView.register(ScheduleCell.self, forCellReuseIdentifier: ScheduleCell.identifier)
		return tableView
	}()
	
	private lazy var addButton: UIButton = {
		let button = UIButton()
		button.setTitle("Готово", for: .normal)
		button.backgroundColor = UIColor(named: "YPBlack")
		button.tintColor = UIColor(named: "YPWhite")
		button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
		button.layer.cornerRadius = 16
		button.addTarget(self, action: #selector(getScheduleFinished), for: .touchUpInside)
		return button
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		setupUIElements()
		setupCollectionView()
	}
	
	private func setupCollectionView() {
		tableView.dataSource = self
		tableView.delegate = self
		view.addSubview(tableView)
		tableView.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
			tableView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 38),
			tableView.heightAnchor.constraint(equalToConstant: CGFloat(WeekDay.allCases.count * 75))
		])
	}
	
	private func setupUIElements() {
		view.addSubview(headerLabel)
		headerLabel.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
			headerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
			headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27)
		])
		
		view.addSubview(addButton)
		addButton.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			addButton.heightAnchor.constraint(equalToConstant: 60),
			addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
			addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
			addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
		])
	}
	
	@objc private func getScheduleFinished() {
		delegate?.getScheduleForTracker(weekDays: daysForSchedule)
		dismiss(animated: true)
	}
}

extension ScheduleViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		WeekDay.allCases.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleCell.identifier, for: indexPath) as! ScheduleCell
		
		let day = WeekDay.allCases[indexPath.row]
		cell.backgroundColor = UIColor(named: "YPBackground")
		cell.configCell(name: day.getDayOnRussian(), delegate: self, switchedOn: daysForSchedule.contains(day))
		return cell
	}
}

extension ScheduleViewController: IScheduleCellDelegate {
	func switchDidChange(_ cell: ScheduleCell) {
		guard let indexPath = tableView.indexPath(for: cell) else { return }
		let day = WeekDay.allCases[indexPath.row]
		
		if !daysForSchedule.contains(day) {
			daysForSchedule.insert(day)
			tableView.reloadRows(at: [indexPath], with: .automatic)
		} else {
			daysForSchedule.remove(day)
			tableView.reloadRows(at: [indexPath], with: .automatic)
		}
	}
}
