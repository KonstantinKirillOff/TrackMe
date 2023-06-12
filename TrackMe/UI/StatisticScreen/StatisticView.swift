//
//  StatisticView.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 10.06.2023.
//

import UIKit

enum StatisticType: CaseIterable {
	case bestPeriod
	case perfectDays
	case completedTrackers
	case averageValue
	
	var titleStatistic: String {
		switch self {
		case .bestPeriod:
			return NSLocalizedString("bestPeriod", comment: "title for Best period statistic label")
		case .perfectDays:
			return NSLocalizedString("perfectPeriod", comment: "title for Perfect period statistic label")
		case .completedTrackers:
			return NSLocalizedString("completedTrackers", comment: "title for completed trackers statistic label")
		case .averageValue:
			return NSLocalizedString("averageValue", comment: "title for average value statistic label")
		}
	}
}

final class StatisticView: UIView {
	private lazy var stackView: UIStackView = {
		let stackView = UIStackView()
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.distribution = .fill
		stackView.axis = .vertical
		stackView.backgroundColor = .clear
		return stackView
	}()
	
	private lazy var statisticNameLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = Colors.ypBlack
		label.font = UIFont.ypMediumSize12
		label.textAlignment = .left
		return label
	}()
	
	private lazy var statisticCountLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = Colors.ypBlack
		label.font = UIFont.ypBoldSize34
		label.textAlignment = .left
		return label
	}()
	
	private lazy var borderLayer: CAGradientLayer = {
		let gradientLayer = CAGradientLayer()
		gradientLayer.colors = [
			Colors.ypGradient1.cgColor,
			Colors.ypGradient2.cgColor,
			Colors.ypGradient3.cgColor
		]
		gradientLayer.startPoint = CGPoint(x: 1, y: 0.5)
		gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.5)
		return gradientLayer
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupView()
		addSubviews()
		activateConstraints()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func config(type: StatisticType, countForStatistic: Int) {
		statisticNameLabel.text = type.titleStatistic
		statisticCountLabel.text = String(countForStatistic)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		borderLayer.frame = bounds
		
		let mask = CAShapeLayer()
		let rect = bounds.insetBy(dx: 0.5, dy: 0.5)
		mask.path = UIBezierPath(roundedRect: rect, cornerRadius: 16).cgPath
		mask.lineWidth = 1
		mask.fillColor = UIColor.clear.cgColor
		mask.strokeColor = UIColor.white.cgColor
		borderLayer.mask = mask
	}
	
	private func setupView() {
		backgroundColor = .clear
		layer.addSublayer(borderLayer)
	}

	private func addSubviews() {
		addSubViews(stackView)
		stackView.addArrangedSubview(statisticCountLabel)
		stackView.addArrangedSubview(statisticNameLabel)
	}
	
	private func activateConstraints() {
		NSLayoutConstraint.activate([
			stackView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
			stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
			stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
			stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
		])
	}
}
