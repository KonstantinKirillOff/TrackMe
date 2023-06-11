//
//  StatisticsViewController.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 13.04.2023.
//

import UIKit

final class StatisticsViewController: UIViewController {
	private let statisticProvider: StatisticProviderProtocol
	
	private lazy var plugView = PlugView(frame: .zero)
	private lazy var statisticLabelsArray: [StatisticView] = []
	
	private lazy var stackView: UIStackView = {
		let stackView = UIStackView()
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.distribution = .fillEqually
		stackView.axis = .vertical
		stackView.backgroundColor = .clear
		stackView.spacing = 10
		return stackView
	}()
	
	init(statisticProvider: StatisticProviderProtocol) {
		self.statisticProvider = statisticProvider
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupView()
		addSubviews()
		activateConstraints()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		plugView.isHidden = statisticProvider.isTrackersInCoreData
		statisticLabelsArray.forEach { $0.isHidden = !statisticProvider.isTrackersInCoreData }
	}
	
	private func setupView() {
		view.backgroundColor = Colors.backgroundColor
		if let navBar = navigationController?.navigationBar {
			title = NSLocalizedString("tabBarItemStatistics", comment: "Text displayed on tapBat for statistics screen")
			navBar.prefersLargeTitles = true
		}
	}
	
	private func addSubviews() {
		view.addSubViews(plugView, stackView)
		statisticLabelsArray = StatisticType.allCases.enumerated().compactMap({ (index, type)  in
			let statisticView = StatisticView()
			let countForStatistic: Int
			switch type {
			case .bestPeriod:
				countForStatistic = statisticProvider.bestPeriod
			case .perfectDays:
				countForStatistic = statisticProvider.perfectDays
			case .completedTrackers:
				countForStatistic = statisticProvider.completedTrackers
			case .averageValue:
				countForStatistic = statisticProvider.averageValue
			}
			statisticView.config(type: type, countForStatistic: countForStatistic)
			return statisticView
		})
		statisticLabelsArray.forEach {
			stackView.addArrangedSubview($0)
		}
	}
	
	private func activateConstraints() {
		NSLayoutConstraint.activate([
			plugView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			plugView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
			
			stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
			stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
		])
		
		statisticLabelsArray.forEach {
			$0.heightAnchor.constraint(equalToConstant: 90).isActive = true
		}
	}
}
