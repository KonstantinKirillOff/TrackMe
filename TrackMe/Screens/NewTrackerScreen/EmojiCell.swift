//
//  EmojiCell.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 29.04.2023.
//

//
//  TrackerCell.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 13.04.2023.
//

import UIKit

final class EmojiCell: UICollectionViewCell {
	static let identifier = "emojiCell"
	
	private lazy var emojiLabel: UILabel = {
		let emojiLabel = UILabel()
		emojiLabel.font = UIFont.systemFont(ofSize: 30, weight: .bold)
		return emojiLabel
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		contentView.layer.cornerRadius = 16
		contentView.backgroundColor = Colors.ypWhite
		
		setupEmojiView()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		assertionFailure("init(coder:) has not been implemented")
	}
	
	private func setupEmojiView() {
		contentView.addSubview(emojiLabel)

		emojiLabel.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			emojiLabel.heightAnchor.constraint(equalToConstant: 38),
			emojiLabel.widthAnchor.constraint(equalToConstant: 32),
			emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
			emojiLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
			emojiLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 7),
			emojiLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -7)
		])
	}
	
	func configCell(for emoji: String, isSelected: Bool) {
		emojiLabel.text = emoji
	
		if !isSelected {
			contentView.backgroundColor = Colors.ypWhite
		} else {
			contentView.backgroundColor = Colors.ypLightGray
		}
	}
}

