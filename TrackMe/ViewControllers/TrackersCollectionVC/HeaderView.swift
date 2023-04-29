//
//  HeaderView.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 16.04.2023.
//

import UIKit

final class HeaderView: UICollectionReusableView {
	static let identifier = "headerView"
	var headerTittle = UILabel()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		headerTittle.font = UIFont.systemFont(ofSize: 19, weight: .bold)
		addSubview(headerTittle)
		headerTittle.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			headerTittle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28),
			headerTittle.topAnchor.constraint(equalTo: topAnchor),
			headerTittle.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 12)
		])
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
