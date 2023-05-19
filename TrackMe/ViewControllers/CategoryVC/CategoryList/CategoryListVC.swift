//
//  CategoryListVC.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 18.05.2023.
//

import UIKit

final class CategoryListViewController: UIViewController {
	private lazy var headerLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
		label.text = "Категория"
		label.textAlignment = .center
		return label
	}()
	
	private lazy var addCategoryButton: UIButton = {
		let button = UIButton()
		button.setTitle("Добавить категорию", for: .normal)
		button.backgroundColor = UIColor.ypBlack
		button.tintColor = UIColor.ypWhite
		button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
		button.layer.cornerRadius = 16
		button.addTarget(self, action: #selector(addCategoryButtonPressed), for: .touchUpInside)
		return button
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
	
	private lazy var emptyStub: UIStackView = {
		let image = UIImageView(image: UIImage(named: "EmptyTrackers") ?? UIImage())
		let titleLabel = UILabel()
		titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
		titleLabel.numberOfLines = 2
		titleLabel.text = """
		Привычки и события
		можно объединить по смыслу
		"""
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
		setupUIElements()
		setupStubEmpty()
	}
	
	private func setupView() {
		view.backgroundColor = UIColor.ypWhite
	}
	
	private func setupUIElements() {
		view.addSubview(headerLabel)
		headerLabel.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
			headerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
			headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27)
		])
		
		view.addSubview(addCategoryButton)
		addCategoryButton.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
			addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
			addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
			addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
		])
	}
	
	private func setupStubEmpty() {
		view.addSubview(emptyStub)
		emptyStub.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			emptyStub.centerYAnchor.constraint(equalTo: tableView.centerYAnchor),
			emptyStub.centerXAnchor.constraint(equalTo: tableView.centerXAnchor)
		])
	}
	
	@objc private func addCategoryButtonPressed(_ sender: UIButton) {
		let createCategoryVC = NewCategoryViewController()
		present(createCategoryVC, animated: true)
	}
}
