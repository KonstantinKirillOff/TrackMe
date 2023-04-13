//
//  TrackersViewController.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 13.04.2023.
//

import UIKit

final class TrackersViewController: UIViewController {
	private var trackers = ["1", "2"]
	
	private lazy var datePicker: UIDatePicker = {
		let datePicker = UIDatePicker()
		datePicker.preferredDatePickerStyle = .compact
		datePicker.datePickerMode = .date
		datePicker.addTarget(self, action: #selector(showTrackersOnDate), for: .editingDidEnd)
		return datePicker
	}()
	
	private let collectionView: UICollectionView = {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
		collectionView.register(CardTrackerCell.self, forCellWithReuseIdentifier: CardTrackerCell.identifier)
		return collectionView
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupView()
		setupCollectionView()
	}
	
	private func setupView() {
		view.backgroundColor = .white
		
		if let navBar = navigationController?.navigationBar {
			title = "Трэкеры"
			navBar.prefersLargeTitles = true
			  
			let leftButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(openAddNewTrackerVC))
			leftButton.tintColor = .label
			navigationItem.leftBarButtonItem = leftButton
			
			let rightItem = UIBarButtonItem(customView: datePicker)
			navigationItem.rightBarButtonItem = rightItem
		}
	}
	
	private func setupCollectionView() {
		
		view.addSubview(collectionView)
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
			collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
		])
		
		collectionView.dataSource = self
		collectionView.delegate = self
	}
	
	@objc private func openAddNewTrackerVC() {
		print("addTrackerVC")
	}
	
	@objc private func showTrackersOnDate() {
		let newDate = datePicker.date
		print("\(newDate)")
	}
}

extension TrackersViewController: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		trackers.count

	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardTrackerCell.identifier, for: indexPath) as! CardTrackerCell
		
		let tracker = trackers[indexPath.row]
		
		cell.title.text = tracker
		
		return cell
	}
}

extension TrackersViewController: UICollectionViewDelegate {
	
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
	
}
