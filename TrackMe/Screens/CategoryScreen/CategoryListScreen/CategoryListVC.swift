//
//  CategoryListVC.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 18.05.2023.
//

import UIKit

protocol ICategoryListViewControllerDelegate: AnyObject {
	func categoryDidSelected(category: CategoryElementViewModel, vc: CategoryListViewController)
}

final class CategoryListViewController: UIViewController {
	weak var delegate: ICategoryListViewControllerDelegate?
	
	private var alertPresenter: IAlertPresenterProtocol!
	private var viewModel: CategoryListViewModel!
	
	private lazy var headerLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
		label.text = "Категория"
		label.textAlignment = .center
		label.translatesAutoresizingMaskIntoConstraints = false
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
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	private lazy var tableView: UITableView = {
		let tableView = UITableView()
		tableView.rowHeight = 75
		tableView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
		tableView.layer.masksToBounds = true
		tableView.layer.cornerRadius = 16
		tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
		tableView.register(CategoryListCell.self, forCellReuseIdentifier: CategoryListCell.identifier)
		tableView.translatesAutoresizingMaskIntoConstraints = false
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
		titleLabel.textAlignment = .center
		
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
	
	override func viewDidLoad() {
		super.viewDidLoad()
		alertPresenter = AlertPresenter(delegate: self)
		
		setupView()
		setupUIElements()
		setupTableView()
		setupStubEmpty()
		checkEmptyCategories()
	}
	
	func initialise(viewModel: CategoryListViewModel) {
		self.viewModel = viewModel
		bind()
	}
	
	func checkEmptyCategories() {
		emptyStub.isHidden = !viewModel.categoryListIsEmpty()
	}
	
	private func bind() {
		guard let viewModel = viewModel else { return }
		viewModel.$categories.bind { [weak self] _ in
			guard let self = self else { return }
			self.tableView.reloadData()
		}
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
		
		view.addSubview(addCategoryButton)
		NSLayoutConstraint.activate([
			addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
			addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
			addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
			addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
		])
	}
	
	private func setupTableView() {
		tableView.dataSource = self
		tableView.delegate = self
		
		view.addSubview(tableView)
		NSLayoutConstraint.activate([
			tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
			tableView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 27),
			tableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -10)
		])
	}
	
	private func setupStubEmpty() {
		view.addSubview(emptyStub)
		NSLayoutConstraint.activate([
			emptyStub.centerYAnchor.constraint(equalTo: tableView.centerYAnchor),
			emptyStub.centerXAnchor.constraint(equalTo: tableView.centerXAnchor)
		])
	}
	
	private func deleteCategory(indexPath: IndexPath) {
		let deleteAction = UIAlertAction(title: "Удалить",
										 style: .destructive) { [weak self] _ in
			guard let self = self else { return }
			let category = self.viewModel.categories[indexPath.row]
			do {
				try self.viewModel.deleteCategory(by: category.id)
				self.checkEmptyCategories()
			} catch {
				//TODO: show alert
				print("Category: \(category.name) don't deleted!")
			}
		}
		
		let closeAction = UIAlertAction(title: "Отменить",
										style: .cancel)
		
		alertPresenter.preparingAlertController(alertTitle: nil,
												alertMessage: "Эта категория точно не нужна?",
												alertActions: [deleteAction, closeAction],
												alertType: .actionSheet)
	}
	
	private func changeCategory(indexPath: IndexPath) {
		let category = viewModel.categories[indexPath.row]
		let changeCategoryVC = ChangeCategoryViewController()
		changeCategoryVC.delegate = self
		changeCategoryVC.initialise(category: category)
		present(changeCategoryVC, animated: true)
	}
	
	@objc private func addCategoryButtonPressed(_ sender: UIButton) {
		let createCategoryVC = NewCategoryViewController()
		let categoryModel = CategoryModel(categoryStore: TrackerCategoryStore())
		let categoryVM = CategoryViewModel(for: categoryModel)
		createCategoryVC.delegate = self
		createCategoryVC.initialise(viewModel: categoryVM)
		present(createCategoryVC, animated: true)
	}
}

extension CategoryListViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		viewModel.categories.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: CategoryListCell.identifier, for: indexPath) as! CategoryListCell
		let category = viewModel.categories[indexPath.row]
		cell.configCell(name: category.name, isSelectedCategory: category.selectedCategory)
		return cell
	}
}

extension CategoryListViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let category = viewModel.categories[indexPath.row]
		viewModel.selectCategory(category: category)
		delegate?.categoryDidSelected(category: category, vc: self)
	}
	
	func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		return UIContextMenuConfiguration(actionProvider: { actions in
			return UIMenu(children: [
				UIAction(title: "Редактировать", handler: { [weak self] _ in
					self?.changeCategory(indexPath: indexPath)
				}),
				UIAction(title: "Удалить",attributes: .destructive, handler: { [weak self] _ in
					self?.deleteCategory(indexPath: indexPath)
				})
			])
		})
	}
}

extension CategoryListViewController: INewCategoryViewControllerDelegate {
	func newCategoryDidAdd(vc: NewCategoryViewController) {
		vc.dismiss(animated: true) { [weak self] in
			guard let self = self else { return }
			self.tableView.reloadData()
			self.checkEmptyCategories()
		}
	}
}

extension CategoryListViewController: IChangeCategoryViewControllerDelegate {
	func categoryDidChange(category: CategoryElementViewModel, vc: ChangeCategoryViewController) {
		vc.dismiss(animated: true) { [weak self] in
			guard let self = self else { return }
			do {
				try self.viewModel.changeCategory(by: category.id, trackerCategory: category)
				self.tableView.reloadData()
			} catch {
				//TODO: show alert
				print("Category: \(category.name) don't changed!")
			}
		}
	}
}

extension CategoryListViewController: IAlertPresenterDelegate {
	func showAlert(alert: UIAlertController) {
		self.present(alert, animated: true)
	}
}
