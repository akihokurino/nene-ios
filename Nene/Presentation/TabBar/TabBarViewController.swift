//
//  TabBarViewController.swift
//  Neon
//
//  Created by akiho on 2019/01/04.
//  Copyright © 2019 akiho. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class TabBarViewController: UITabBarController {
    
    private let disposeBag = DisposeBag()
    
    static func instantiate() -> TabBarViewController {
        return R.storyboard.tabBar.tabBarViewController()!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabs()
        bind()
    }
    
    private func setupTabs() {
        delegate = self
        
        var viewControllers: [UIViewController] = []
        
        let homeTab = UITabBarItem(
            title: "ホーム",
            image: R.image.icon_home()!,
            selectedImage: R.image.icon_home()!)
        let homeNav = NavigationController(rootViewController: HomeViewController.instantiate())
        homeNav.tabBarItem = homeTab
        viewControllers.append(homeNav)
        
        let profileTab = UITabBarItem(
            title: "プロフィール",
            image: R.image.icon_profile()!,
            selectedImage: R.image.icon_profile()!)
        let profileNav = NavigationController(rootViewController: ProfileViewController.instantiate())
        profileNav.tabBarItem = profileTab
        viewControllers.append(profileNav)
        
        let settingTab = UITabBarItem(
            title: "設定",
            image: R.image.icon_setting()!,
            selectedImage: R.image.icon_setting()!)
        let settingNav = NavigationController(rootViewController: SettingViewController.instantiate())
        settingNav.tabBarItem = settingTab
        viewControllers.append(settingNav)
        
        tabBar.isTranslucent = false
        
        setViewControllers(viewControllers, animated: false)
    }
    
    private func bind() {
        let vm = TabBarViewModel(
            dependency: .init(
                userUseCase: DomainAssembly.injectUserUseCase(),
                notificationSettingUseCase: DomainAssembly.injectNotificationSettingUseCase()
            )
        )
        
        let output = vm.transform(input: .init(
            viewWillAppear: rx.viewWillAppear.asDriver()
        ))
        
        output.updatedFCMToken
            .drive()
            .disposed(by: disposeBag)
    }
}

extension TabBarViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true
    }
}
