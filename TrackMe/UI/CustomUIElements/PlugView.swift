//
//  PlugView.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 10.06.2023.
//

import UIKit

final class PlugView: UIStackView {
	private lazy var plugImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.contentMode = .scaleAspectFit
		return imageView
	}()
	
	private lazy var plugLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = Colors.ypBlack
		label.font = UIFont.ypMediumSize12
		label.textAlignment = .center
		label.numberOfLines = 0
		return label
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupView()
		addSubview()
		plugLabel.text = NSLocalizedString("statisticPlug", comment: "Text for statistic plugView")
		plugImageView.image = UIImage(named: "noAnalyze") ?? UIImage()
	}
	
	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setupView() {
		backgroundColor = .clear
		translatesAutoresizingMaskIntoConstraints = false
		distribution = .fill
		axis = .vertical
		spacing = 8
	}
	
	private func addSubview() {
		addArrangedSubview(plugImageView)
		addArrangedSubview(plugLabel)
	}
}
