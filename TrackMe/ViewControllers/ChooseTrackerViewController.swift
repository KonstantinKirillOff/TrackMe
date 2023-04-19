//
//  ChooseTrackerViewController.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 17.04.2023.
//

import UIKit

protocol IChooseTrackerViewControllerDelegate: AnyObject {
	func newTrackerDidAdd(tracker: Tracker, categoryName: String, vc: ChooseTrackerViewController)
}

final class ChooseTrackerViewController: UIViewController {
	weak var delegate: IChooseTrackerViewControllerDelegate?
	
	private lazy var headerLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 16)
		label.text = "Создание трэкера"
		label.textAlignment = .center
		return label
	}()
	
	private lazy var habitButton: UIButton = {
		let button = UIButton()
		button.setTitle("Привычка", for: .normal)
		button.backgroundColor = UIColor(named: "YPBlack")
		button.tintColor = UIColor(named: "YPWhite")
		button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
		button.layer.cornerRadius = 16
		button.addTarget(self, action: #selector(habitButtonPressed), for: .touchUpInside)
		return button
	}()
	
	private lazy var unregularActivityButton: UIButton = {
		let button = UIButton()
		button.setTitle("Нерегулярное событие", for: .normal)
		button.backgroundColor = UIColor(named: "YPBlack")
		button.tintColor = UIColor(named: "YPWhite")
		button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
		button.layer.cornerRadius = 16
		button.addTarget(self, action: #selector(unregularActivityButtonPressed), for: .touchUpInside)
		return button
	}()
	
	private lazy var buttonsStackView: UIStackView = {
		let stackView = UIStackView()
		stackView.axis = .vertical
		stackView.alignment = .fill
		stackView.distribution = .fillEqually
		stackView.spacing = 16
		stackView.addArrangedSubview(habitButton)
		stackView.addArrangedSubview(unregularActivityButton)
		return stackView
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupView()
		setupUIElements()
	}
	
	private func setupView() {
		view.backgroundColor = .white
	}
	
	private func setupUIElements() {
		view.addSubview(headerLabel)
		headerLabel.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
			headerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
			headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27)
		])
		
		view.addSubview(buttonsStackView)
		buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			buttonsStackView.heightAnchor.constraint(equalToConstant: 136),
			buttonsStackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
			buttonsStackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
			buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
			buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
		])
	}
	
	@objc private func habitButtonPressed(_ sender: UIButton) {
		let newTrackerVC = NewTrackerViewController()
		newTrackerVC.configViewController(header: "Новая привычка", trackerTypes: ["Категория", "Расписание"], delegate: self)
		present(newTrackerVC, animated: true)
	}
	
	@objc private func unregularActivityButtonPressed(_ sender: UIButton) {
		let newTrackerVC = NewTrackerViewController()
		newTrackerVC.configViewController(header: "Новое нерегулярное событие", trackerTypes: ["Категория"], delegate: self)
		present(newTrackerVC, animated: true)
	}
}

extension ChooseTrackerViewController: INewTrackerViewControllerDelegate {
	func newTrackerDidAdd(tracker: Tracker, categoryName: String, vc: NewTrackerViewController) {
		vc.dismiss(animated: true) { [weak self] in
			guard let self = self else { return }
			self.delegate?.newTrackerDidAdd(tracker: tracker, categoryName: categoryName , vc: self)
		}
	}
}
