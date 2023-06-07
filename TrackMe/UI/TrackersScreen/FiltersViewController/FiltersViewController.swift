//
//  FiltersViewController.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 06.06.2023.
//

import UIKit

final class FiltersViewController: UIViewController {
	
	private struct ViewControllerConstant {
		static let titleViewController = NSLocalizedString("filterTitle", comment: "Title view controller")
		static let collectionViewReuseIdentifier = "Cell"
	}
	
	private let provider: FilterCollectionViewProviderProtocol
	private let selectedFilter: FilterType
	
	init(selectedFilter: FilterType, provider: FilterCollectionViewProviderProtocol) {
		self.selectedFilter = selectedFilter
		self.provider = provider
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private lazy var filterCollectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		layout.scrollDirection = .vertical
		let collectionView = UICollectionView(
			frame: .zero,
			collectionViewLayout: layout
		)
		collectionView.register(
			UICollectionViewCell.self,
			forCellWithReuseIdentifier: ViewControllerConstant.collectionViewReuseIdentifier
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
	
	// MARK: - override
	override func viewDidLoad() {
		super.viewDidLoad()
		setupView()
		addViews()
		activateConstraints()
		provider.setFilter(selectedFilter: selectedFilter)
	}
	
	// MARK: - private methods
	private func setupView() {
		title = NSLocalizedString("filterTitle", comment: "Title view controller")
		view.backgroundColor = Colors.backgroundColor
	}
	
	private func addViews() {
		view.addSubview(filterCollectionView)
	}
	
	private func activateConstraints() {
		NSLayoutConstraint.activate([
			filterCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			filterCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			filterCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
			filterCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
		])
	}
}
