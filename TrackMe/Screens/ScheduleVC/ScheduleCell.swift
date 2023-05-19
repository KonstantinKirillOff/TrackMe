//
//  ScheduleCell.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 17.04.2023.
//

import UIKit

protocol IScheduleCellDelegate: AnyObject {
	func switchDidChange(_ cell: ScheduleCell)
}

final class ScheduleCell: UITableViewCell {
	static let identifier = "scheduleCell"
	weak var delegate: IScheduleCellDelegate?

	private lazy var nameDayOfWeek: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
		return label
	}()
	
	private lazy var daySwitcher: UISwitch = {
		let switcher = UISwitch()
		switcher.isOn = false
		switcher.addTarget(self, action: #selector(switchedDidChange), for: .valueChanged)
		switcher.onTintColor = UIColor.ypBlue
		return switcher
	}()

	private lazy var stackView: UIStackView = {
		let stackView = UIStackView()
		stackView.axis = .horizontal
		stackView.alignment = .center
		stackView.distribution = .fill
		stackView.addArrangedSubview(nameDayOfWeek)
		stackView.addArrangedSubview(daySwitcher)
		return stackView
	}()

	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupStackView()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		assertionFailure("init(coder:) has not been implemented")
	}
	
	func configCell(name: String, delegate: IScheduleCellDelegate, switchedOn: Bool) {
		self.nameDayOfWeek.text = name
		self.delegate = delegate
		self.daySwitcher.isOn = switchedOn
	}
	
	private func setupStackView() {
		contentView.addSubview(stackView)
		stackView.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 26.5),
			stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -26.5),
			stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
		])
	}
	
	@objc private func switchedDidChange() {
		delegate?.switchDidChange(self)
	}
	
}
