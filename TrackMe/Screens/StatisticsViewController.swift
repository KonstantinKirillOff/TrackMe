//
//  StatisticsViewController.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 13.04.2023.
//

import UIKit

final class StatisticsViewController: UIViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		
		title = "Стастистика"
		navigationController?.navigationBar.prefersLargeTitles = true
		view.backgroundColor = UIColor.ypWhite
	}
}
