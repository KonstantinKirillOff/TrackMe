//
//  TrackerCell.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 13.04.2023.
//

import UIKit

final class CardTrackerCell: UICollectionViewCell {
	static let identifier = "trackerCell"
	let title = UILabel()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		contentView.addSubview(title)
		title.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			title.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
			title.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
		])
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
