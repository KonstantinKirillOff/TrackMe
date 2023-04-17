//
//  ScheduleViewController.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 17.04.2023.
//

import UIKit

final class ScheduleViewController: UIViewController {
	
	private var daysForSchedule = [Int]()
	
	private lazy var collectionView: UICollectionView = {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
		collectionView.register(ScheduleCell.self, forCellWithReuseIdentifier: ScheduleCell.identifier)
		return collectionView
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = .red
	}
}
