//
//  ChangeCategoryVC.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 21.05.2023.
//

import UIKit

protocol IChangeCategoryViewControllerDelegate: AnyObject {
	func categoryDidChange(category: CategoryElementViewModel, vc: ChangeCategoryViewController)
}

final class ChangeCategoryViewController: UIViewController {
	private var categoryForChange: CategoryElementViewModel!
	weak var delegate: IChangeCategoryViewControllerDelegate?
	
	private lazy var headerLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
		label.text = "Редактирование категории"
		label.textAlignment = .center
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private lazy var categoryNameTextField: UITextField = {
		let textField = BaseTextField()
		textField.placeholder  = "Введите название категории"
		textField.translatesAutoresizingMaskIntoConstraints = false
		return textField
	}()
	
	private lazy var changeCategoryButton: UIButton = {
		let button = UIButton()
		button.setTitle("Готово", for: .normal)
		button.backgroundColor = Colors.ypBlack
		button.tintColor = Colors.ypWhite
		button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
		button.layer.cornerRadius = 16
		button.addTarget(self, action: #selector(changeCategoryButtonPressed), for: .touchUpInside)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		categoryNameTextField.text = categoryForChange.name
		setupView()
		setupUIElements()
	}
	
	private func setupView() {
		view.backgroundColor = Colors.backgroundColor
	}
	
	private func setupUIElements() {
		view.addSubview(headerLabel)
		NSLayoutConstraint.activate([
			headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
			headerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
			headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27)
		])
		
		view.addSubview(categoryNameTextField)
		NSLayoutConstraint.activate([
			categoryNameTextField.heightAnchor.constraint(equalToConstant: 75),
			categoryNameTextField.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 38),
			categoryNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			categoryNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
		])
		
		view.addSubview(changeCategoryButton)
		NSLayoutConstraint.activate([
			changeCategoryButton.heightAnchor.constraint(equalToConstant: 60),
			changeCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
			changeCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
			changeCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
		])
	}
	
	func initialise(category: CategoryElementViewModel) {
		self.categoryForChange = category
	}
	
	@objc
	private func changeCategoryButtonPressed(_ sender: UIButton) {
		guard let categoryName = categoryNameTextField.text else { return }
		let category = CategoryElementViewModel(id: categoryForChange.id,
												name: categoryName,
												selectedCategory: categoryForChange.selectedCategory)
		delegate?.categoryDidChange(category: category, vc: self)
	}
}
