//
//  CategoryListCell.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 18.05.2023.
//

import UIKit

//protocol ICategoryCellDelegate: AnyObject {
//	func categoryCellDidTap(_ cell: CategoryListCell)
//}

final class CategoryListCell: UITableViewCell {
	static let identifier = "categoryCell"
	//weak var delegate: ICategoryCellDelegate?
	
	private lazy var categoryNameLabel: UILabel = {
		let label = UILabel()
		label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
		return label
	}()
	
	lazy var checkMarkImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.image = UIImage(named: "checkmark")
		return imageView
	}()
	
	private lazy var stackView: UIStackView = {
		let stackView = UIStackView()
		stackView.axis = .horizontal
		stackView.alignment = .center
		stackView.distribution = .fill
		stackView.addArrangedSubview(categoryNameLabel)
		stackView.addArrangedSubview(checkMarkImageView)
		stackView.translatesAutoresizingMaskIntoConstraints = false
		return stackView
	}()
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		setupView()
		setupUIElements()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		assertionFailure("init(coder:) has not been implemented")
	}
	
	private func setupView() {
		contentView.layer.cornerRadius = 16
		contentView.backgroundColor = UIColor.ypBackground
		selectionStyle = .none
	}
	
	private func setupUIElements() {
		contentView.addSubview(stackView)

		NSLayoutConstraint.activate([
			stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 26.5),
			stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -26.5),
			stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
			stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
		])
	}
	
	//, delegate: ICategoryCellDelegate
	func configCell(name: String, isSelectedCategory: Bool) {
		self.categoryNameLabel.text = name
		//self.delegate = delegate
		self.checkMarkImageView.isHidden = !isSelectedCategory
	}
}
