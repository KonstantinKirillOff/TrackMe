//
//  OnboardingViewController.swift
//  TrackMe
//
//  Created by Konstantin Kirillov on 15.05.2023.
//

import UIKit

final class OnboardingViewController: UIPageViewController {
	let settingsManager = SettingsManager.shared
	
	lazy var pages: [UIViewController] = {
		let screenOne = OnboardingScreenOneViewController()
		let screenTwo = OnboardingScreenTwoViewController()
		return [screenOne, screenTwo]
	}()
	
	lazy var pageControl: UIPageControl = {
		let pageControl = UIPageControl()
		pageControl.numberOfPages = pages.count
		pageControl.currentPage = 0
		
		pageControl.currentPageIndicatorTintColor = Colors.ypBlack
		pageControl.pageIndicatorTintColor = Colors.ypGray
		
		pageControl.translatesAutoresizingMaskIntoConstraints = false
		return pageControl
	}()
	
	lazy var onboardingFinishButton: UIButton = {
		let button = UIButton()
		button.setTitle("Вот это технологии!", for: .normal)
		button.backgroundColor = UIColor.black
		button.setTitleColor(UIColor.white, for: .normal)
		button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
		button.layer.cornerRadius = 16
		button.addTarget(self, action: #selector(finishButtonTapped), for: .touchUpInside)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()

    override func viewDidLoad() {
        super.viewDidLoad()
		dataSource = self
		delegate = self
		if let firstScreen = pages.first {
			setViewControllers([firstScreen], direction: .forward, animated: true)
		}
		setupUIElements()
    }
	
	private func setupUIElements() {
		view.addSubview(onboardingFinishButton)
		NSLayoutConstraint.activate([
			onboardingFinishButton.heightAnchor.constraint(equalToConstant: 60),
			onboardingFinishButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
			onboardingFinishButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
			onboardingFinishButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
		])
		
		view.addSubview(pageControl)
		NSLayoutConstraint.activate([
			pageControl.topAnchor.constraint(equalTo: onboardingFinishButton.topAnchor, constant: -24),
			pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
		])
	}
	
	@objc
	private func finishButtonTapped() {
		switchToTapBarController()
	}
	
	private func switchToTapBarController() {
		guard let window = UIApplication.shared.windows.first else {
			assertionFailure("Invalid configuration")
			return
		}
		
		let tabBarVC = TabBarViewController()
		window.rootViewController = tabBarVC
		settingsManager.isNotFirstLaunch = true
	}
}

extension OnboardingViewController: UIPageViewControllerDataSource {
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
			return nil
		}
		
		let prevIndex = viewControllerIndex - 1
		guard prevIndex >= 0 else {
			return nil
		}
		
		return pages[prevIndex]
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
			return nil
		}
		
		let nextIndex = viewControllerIndex + 1
		guard nextIndex < pages.count else {
			return nil
		}
		
		return pages[nextIndex]
	}
}

extension OnboardingViewController: UIPageViewControllerDelegate {
	func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
		if let currentVC = pageViewController.viewControllers?.first,
		   let currentIndex = pages.firstIndex(of: currentVC) {
			pageControl.currentPage = currentIndex
		}
	}
}
