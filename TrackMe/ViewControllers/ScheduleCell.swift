//
//  ScheduleCell.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 17.04.2023.
//

import UIKit

protocol IScheduleCellDelegate: AnyObject {
	func switchDidChange(_ cell: ScheduleCell)
}

final class ScheduleCell: UICollectionViewCell {
	static let identifier = "scheduleCell"
	weak var delegate: IScheduleCellDelegate?
	
//	private lazy var emojiView: UIView = {
//		let emojiView = UIView()
//		return emojiView
//	}()
//
//	private lazy var emojiLabel: UILabel = {
//		let emojiLabel = UILabel()
//		emojiLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
//		return emojiLabel
//	}()
//
//	private lazy var titleLabel: UILabel = {
//		let titleLabel = UILabel()
//		titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
//		titleLabel.textColor = .white
//		titleLabel.numberOfLines = 2
//		return titleLabel
//	}()
//
//	private lazy var cardStackView: UIStackView = {
//		let stackView = UIStackView()
//		stackView.axis = .vertical
//		stackView.alignment = .leading
//		stackView.distribution = .fillProportionally
//		stackView.addArrangedSubview(emojiView)
//		stackView.addArrangedSubview(titleLabel)
//		return stackView
//	}()
//
//	private lazy var cardView: UIView = {
//		let cardView = UIView()
//		cardView.layer.cornerRadius = 16
//		cardView.layer.masksToBounds = true
//		return cardView
//	}()
//
//	private lazy var addQuantityButton: UIButton = {
//		let addButton = UIButton()
//		addButton.tintColor = .white
//		addButton.layer.cornerRadius = 17
//		return addButton
//	}()
//
//	private lazy var quantityLabel: UILabel = {
//		let quantityLabel = UILabel()
//		quantityLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
//		quantityLabel.textColor = .black
//		quantityLabel.textAlignment = .left
//		return quantityLabel
//	}()
//
//	private lazy var quantityStackView: UIStackView = {
//		let stackView = UIStackView()
//		stackView.axis = .horizontal
//		stackView.alignment = .center
//		stackView.distribution = .fillProportionally
//		stackView.addArrangedSubview(quantityLabel)
//		stackView.addArrangedSubview(addQuantityButton)
//		return stackView
//	}()
//
//	var addRecord: (() -> Void)?
//
	override init(frame: CGRect) {
		super.init(frame: frame)
		backgroundColor = .red
//		setupCardView()
//		setupEmojiView()
//		setupCardStackView()
//		setupQuantityButton()
//		setupQuantityStackView()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
//	private func setupCardView() {
//		contentView.addSubview(cardView)
//		cardView.translatesAutoresizingMaskIntoConstraints = false
//
//		NSLayoutConstraint.activate([
//			cardView.heightAnchor.constraint(equalToConstant: 90),
//			cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
//			cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//			cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
//		])
//	}
	
}
