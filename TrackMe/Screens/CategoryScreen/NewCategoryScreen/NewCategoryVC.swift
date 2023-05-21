//
//  NewCategoryVC.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 18.05.2023.
//

import UIKit

protocol INewCategoryViewControllerDelegate: AnyObject {
	func newCategoryDidAdd(vc: NewCategoryViewController)
}

final class NewCategoryViewController: UIViewController {
	weak var delegate: INewCategoryViewControllerDelegate?
	
	private var categoryNameIsEmptyBinding: NSObject?
	private var viewModel: CategoryViewModel?
	
	
	private lazy var headerLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
		label.text = "Новая категория"
		label.textAlignment = .center
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private lazy var categoryNameTextField: UITextField = {
		let textField = BaseTextField()
		textField.placeholder  = "Введите название категории"
		textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
		textField.translatesAutoresizingMaskIntoConstraints = false
		return textField
	}()
	
	private lazy var addCategoryButton: UIButton = {
		let button = UIButton()
		button.setTitle("Готово", for: .normal)
		button.backgroundColor = UIColor.ypBlack
		button.tintColor = UIColor.ypWhite
		button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
		button.layer.cornerRadius = 16
		button.addTarget(self, action: #selector(addCategoryButtonPressed), for: .touchUpInside)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupView()
		setupUIElements()
		setupAccessForElements()
	}
	
	private func setupView() {
		view.backgroundColor = UIColor.ypWhite
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
		
		view.addSubview(addCategoryButton)
		NSLayoutConstraint.activate([
			addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
			addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
			addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
			addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
		])
	}
	
	func initialise(viewModel: CategoryViewModel) {
		self.viewModel = viewModel
		bind()
	}
	
	private func setupAccessForElements() {
		let categoryNameIsEmpty = (categoryNameTextField.text ?? "").isEmpty
		setButtonAvailability(isBlocked: categoryNameIsEmpty)
	}
	
	private func bind() {
		guard let viewModel = viewModel else { return }
		
		categoryNameIsEmptyBinding = viewModel.observe(\.categoryNameIsEmpty,
												   options: [.new],
												   changeHandler: { [weak self] _, change in
			
			guard let newValue = change.newValue else { return }
			self?.setButtonAvailability(isBlocked: newValue)
		})
	}
	
	private func setButtonAvailability(isBlocked: Bool) {
		addCategoryButton.isUserInteractionEnabled = !isBlocked
		addCategoryButton.backgroundColor = !isBlocked ? UIColor.ypBlack : UIColor.ypLightGray
	}
	
	@objc
	private func textFieldDidChange() {
		viewModel?.checkCategoryName(name: categoryNameTextField.text)
	}

	@objc
	private func addCategoryButtonPressed(_ sender: UIButton) {
		guard let categoryName = categoryNameTextField.text else { return }
		let newCategory = TrackerCategory(id: UUID(),
										  name: categoryName,
										  trackers: [])
		viewModel?.addNewCategory(category: newCategory)
		delegate?.newCategoryDidAdd(vc: self)
	}
}
