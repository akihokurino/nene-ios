//
//  SettingViewController.swift
//  Neon
//
//  Created by akiho on 2019/01/11.
//  Copyright © 2019 akiho. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class SettingViewController: UITableViewController {
    
    static func instantiate() -> SettingViewController {
        return R.storyboard.setting.settingViewController()!
    }
    
    private let disposeBag = DisposeBag()
    private let logout: PublishSubject<Void> = PublishSubject()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
    }
    
    private func bind() {
        let vm = SettingViewModel(dependency: .init(
            userUseCase: DomainAssembly.injectUserUseCase()
        ))
        
        let output = vm.transform(input: .init(
            didTapLogoutButton: logout.asDriver(onErrorDriveWith: .empty())
        ))
        
        output.didLogout
            .drive(onNext: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    let nav = NavigationController(rootViewController: PhoneNumberViewController.instantiate())
                    UIApplication.shared.keyWindow?.rootViewController = nav
                }
            })
            .disposed(by: disposeBag)
        
        output.isExecuting
            .drive(rx.isHUDAnimating)
            .disposed(by: disposeBag)
        
        output.error
            .drive(onNext: { [weak self] in
                self?.showAlert(with: $0)
            })
            .disposed(by: disposeBag)
    }
    
    private func createSectionView(index: Int) -> (UIView, CGFloat) {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 20))
        view.backgroundColor = UIColor.background
        return (view, 20)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return createSectionView(index: section).0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return createSectionView(index: section).1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            let vc = SubscriptionViewController.instantiate()
            navigationController?.pushViewController(vc, animated: true)
        case (0, 1):
            let vc = NotificationSettingViewController.instantiate()
            navigationController?.pushViewController(vc, animated: true)
        case (1, 0):
            let vc = WebViewController.instantiate(title: "利用規約", url: StaticConfig.termsURL)
            navigationController?.pushViewController(vc, animated: true)
        case (1, 1):
            let vc = WebViewController.instantiate(title: "プライバシーポリシー", url: StaticConfig.privacyPolicyURL)
            navigationController?.pushViewController(vc, animated: true)
        case (1, 2):
            let vc = WebViewController.instantiate(title: "特定商取引法に基づく表記", url: StaticConfig.commercialCodeURL)
            navigationController?.pushViewController(vc, animated: true)
        case (2, 0):
            logout.onNext(())
        default:
            return
        }
    }
}
