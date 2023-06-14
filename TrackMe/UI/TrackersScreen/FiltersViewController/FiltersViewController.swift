//
//  FiltersViewController.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 06.06.2023.
//

import UIKit

final class FiltersViewController: UIViewController {
	private let provider: FilterCollectionViewProviderProtocol
	private let selectedFilter: FilterType
	
	private lazy var headerLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 16)
		label.text = NSLocalizedString("filterTitle", comment: "Title view controller")
		label.textAlignment = .center
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private lazy var filterCollectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .vertical
		let collectionView = UICollectionView(
			frame: .zero,
			collectionViewLayout: layout
		)
		collectionView.register(
			UICollectionViewCell.self,
			forCellWithReuseIdentifier: "Cell"
		)
		collectionView.register(
			FiltersCollectionViewCell.self,
			forCellWithReuseIdentifier: FiltersCollectionViewCell.cellReuseIdentifier
		)
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		collectionView.showsVerticalScrollIndicator = false
		collectionView.backgroundColor = .clear
		collectionView.dataSource = provider
		collectionView.delegate = provider
		return collectionView
	}()
	
	init(selectedFilter: FilterType, provider: FilterCollectionViewProviderProtocol) {
		self.selectedFilter = selectedFilter
		self.provider = provider
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupView()
		addViews()
		activateConstraints()
		provider.setFilter(selectedFilter: selectedFilter)
	}
	
	private func setupView() {
		title = NSLocalizedString("filterTitle", comment: "Title view controller")
		view.backgroundColor = Colors.backgroundColor
	}
	
	private func addViews() {
		view.addSubview(headerLabel)
		view.addSubview(filterCollectionView)
	}
	
	private func activateConstraints() {
		NSLayoutConstraint.activate([
			headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
			headerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
			headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
			
			filterCollectionView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 38),
			filterCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			filterCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
			filterCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
		])
	}
}
