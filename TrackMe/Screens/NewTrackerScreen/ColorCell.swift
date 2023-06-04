//
//  ColorCell.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 29.04.2023.
//

import UIKit

final class ColorCell: UICollectionViewCell {
	static let identifier = "colorCell"
	
	private lazy var colorView: UIView = {
		let colorView = UIView()
		return colorView
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		contentView.layer.cornerRadius = 8
		contentView.backgroundColor = Colors.ypWhite
		
		setupColorView()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		assertionFailure("init(coder:) has not been implemented")
	}
	
	private func setupColorView() {
		contentView.addSubview(colorView)

		colorView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			colorView.heightAnchor.constraint(equalToConstant: 38),
			colorView.widthAnchor.constraint(equalToConstant: 38),
			colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
			colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
		])
	}
	
	func configCell(for color: UIColor, isSelected: Bool) {
		colorView.backgroundColor = color
		colorView.layer.cornerRadius = 8
	
		if !isSelected {
			contentView.layer.borderWidth = 0
		} else {
			contentView.layer.borderWidth = 3
			contentView.layer.borderColor = color.withAlphaComponent(0.3).cgColor
		}
	}
}
