//
//  TrackerCell.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 13.04.2023.
//

import UIKit
protocol ICardTrackCellDelegate: AnyObject {
	func quantityButtonPressed(_ cell: CardTrackerCell)
}

final class CardTrackerCell: UICollectionViewCell {
	static let identifier = "trackerCell"
	weak var delegate: ICardTrackCellDelegate?
	var interaction: UIContextMenuInteraction? {
		didSet {
			if let interaction { cardView.addInteraction(interaction) }
		}
	}
	
	private lazy var emojiView: UIView = {
		let emojiView = UIView()
		return emojiView
	}()
	
	private lazy var emojiLabel: UILabel = {
		let emojiLabel = UILabel()
		emojiLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
		return emojiLabel
	}()

	private lazy var titleLabel: UILabel = {
		let titleLabel = UILabel()
		titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
		titleLabel.textColor = Colors.ypWhite
		titleLabel.numberOfLines = 2
		return titleLabel
	}()
	
	private lazy var cardStackView: UIStackView = {
		let stackView = UIStackView()
		stackView.axis = .vertical
		stackView.alignment = .leading
		stackView.distribution = .fillProportionally
		stackView.addArrangedSubview(emojiView)
		stackView.addArrangedSubview(titleLabel)
		return stackView
	}()
	
	private lazy var cardView: UIView = {
		let cardView = UIView()
		cardView.layer.cornerRadius = 16
		cardView.layer.masksToBounds = true
		return cardView
	}()
	
	private lazy var addQuantityButton: UIButton = {
		let addButton = UIButton()
		addButton.tintColor = Colors.ypWhite
		addButton.layer.cornerRadius = 17
		return addButton
	}()
	
	private lazy var quantityLabel: UILabel = {
		let quantityLabel = UILabel()
		quantityLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
		quantityLabel.textColor = Colors.ypBlack
		quantityLabel.textAlignment = .left
		return quantityLabel
	}()
	
	private lazy var quantityStackView: UIStackView = {
		let stackView = UIStackView()
		stackView.axis = .horizontal
		stackView.alignment = .center
		stackView.distribution = .fillProportionally
		stackView.addArrangedSubview(quantityLabel)
		stackView.addArrangedSubview(addQuantityButton)
		return stackView
	}()
	
	private lazy var pinImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.image = UIImage(named: "pin")
		imageView.isHidden = true
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupCardView()
		setupEmojiView()
		setupCardStackView()
		setupQuantityButton()
		setupQuantityStackView()
	}
	
	private func setupCardView() {
		contentView.addSubview(cardView)
		cardView.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			cardView.heightAnchor.constraint(equalToConstant: 90),
			cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
			cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
			cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
		])
	}
	
	private func setupEmojiView() {
		cardView.addSubview(emojiView)
		emojiView.addSubview(emojiLabel)
		emojiView.layer.cornerRadius = 12
		emojiView.backgroundColor = Colors.ypWhite?.withAlphaComponent(0.3)
		
		emojiView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			emojiView.heightAnchor.constraint(equalToConstant: 24),
			emojiView.widthAnchor.constraint(equalToConstant: 24)
		])
		
		emojiLabel.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			emojiLabel.centerXAnchor.constraint(equalTo: emojiView.centerXAnchor),
			emojiLabel.centerYAnchor.constraint(equalTo: emojiView.centerYAnchor)
		])
		
		cardView.addSubview(pinImageView)
		pinImageView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			pinImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 18),
			pinImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12)
		])
	}
	
	private func setupCardStackView() {
		cardView.addSubview(cardStackView)
		cardStackView.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			cardStackView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
			cardStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
			cardStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
			cardStackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12)
		])
	}
	
	private func setupQuantityButton() {
		addQuantityButton.addTarget(self, action: #selector(quantityButtonPressed), for: .touchUpInside)
		addQuantityButton.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			addQuantityButton.heightAnchor.constraint(equalToConstant: 34),
			addQuantityButton.widthAnchor.constraint(equalToConstant: 34)
		])
	}
	
	private func setupQuantityStackView() {
		contentView.addSubview(quantityStackView)
		quantityStackView.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			quantityStackView.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 8),
			quantityStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
			quantityStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
			quantityStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
		])
	}
	
	func configCell(for tracker: Tracker, record: Int, tracked: Bool) {
		emojiLabel.text = tracker.emoji
		titleLabel.text = tracker.name
		
		cardView.backgroundColor = tracker.color
		cardView.layer.borderWidth = 1
		cardView.layer.borderColor = tracker.color.withAlphaComponent(0.3).cgColor
	
		if !tracked {
			addQuantityButton.setImage(UIImage(systemName: "plus"), for: .normal)
			addQuantityButton.backgroundColor = tracker.color
		} else {
			addQuantityButton.setImage(UIImage(named: "Done"), for: .normal)
			addQuantityButton.backgroundColor = tracker.color.withAlphaComponent(0.4)
		}
		
		pinImageView.isHidden = !tracker.isPinned
		
		quantityLabel.text = String.localizedStringWithFormat(
			NSLocalizedString("DayCount", comment: "count check days"), record)
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		assertionFailure("init(coder:) has not been implemented")
	}
	
	@objc func quantityButtonPressed(_ sender: UIButton) {
		delegate?.quantityButtonPressed(self)
	}
}
