//
//  OnboardingScreenTwoViewController.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 14.05.2023.
//

import UIKit

final class OnboardingScreenTwoViewController: UIViewController {
	
	lazy var label: UILabel = {
		let label = UILabel()
		label.text = "Даже если это не литры воды и йога"
		label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
		label.numberOfLines = 2
		label.autoresizingMask = .flexibleWidth
		label.textAlignment = .center
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	lazy var imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.image = UIImage(named: "OnboardingScreen2")
		imageView.contentMode = .scaleAspectFill
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setUIElements()
	}
	
	private func setUIElements() {
		view.addSubview(imageView)
		NSLayoutConstraint.activate([
			imageView.topAnchor.constraint(equalTo: view.topAnchor),
			imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])
		
		view.addSubview(label)
		NSLayoutConstraint.activate([
			label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant:  60),
			label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant:  -16),
			label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
		])
	}
}
