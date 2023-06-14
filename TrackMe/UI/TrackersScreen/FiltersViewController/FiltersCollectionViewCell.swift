//
//  FilterCollectionViewCell.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 06.06.2023.
//

import UIKit

final class FiltersCollectionViewCell: UICollectionViewCell {
	static let cellReuseIdentifier = "filterCell"
	
	private lazy var filterLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = UIFont.ypRegularSize17
		label.textColor = Colors.ypBlack
		label.numberOfLines = 0
		return label
	}()
	
	private lazy var checkmarkImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.image = UIImage(named: "checkmark")
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.isHidden = true
		imageView.contentMode = .right
		return imageView
	}()
	
	private lazy var lineView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = Colors.ypGray
		return view
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupView()
		addSubview()
		activateConstraints()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func prepareForReuse() {
		filterLabel.text = nil
		checkmarkImageView.isHidden = true
		lineView.isHidden = false
	}
		
	func config(filterLabelText: String?, checkmarkIsHidden: Bool) {
		filterLabel.text = filterLabelText
		checkmarkImageView.isHidden = !checkmarkIsHidden
	}
	
	func hideLineView() {
		lineView.isHidden = true
	}
	
	private func setupView() {
		backgroundColor = .clear
		contentView.backgroundColor = Colors.ypBackground
	}
	
	private func addSubview() {
		contentView.addSubViews(
			filterLabel,
			checkmarkImageView,
			lineView
		)
	}
	
	private func activateConstraints() {
		contentView.addSubview(filterLabel)
		NSLayoutConstraint.activate([
			filterLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			filterLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			filterLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.75),
			
			checkmarkImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			checkmarkImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
			checkmarkImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.25),
			
			lineView.leadingAnchor.constraint(equalTo: filterLabel.leadingAnchor),
			lineView.trailingAnchor.constraint(equalTo: checkmarkImageView.trailingAnchor),
			lineView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			lineView.heightAnchor.constraint(equalToConstant: 0.5)
		])
	}
}
