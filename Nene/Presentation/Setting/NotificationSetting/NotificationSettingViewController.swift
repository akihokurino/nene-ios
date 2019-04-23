//
//  NotificationSettingViewController.swift
//  Nene
//
//  Created by akiho on 2019/01/13.
//  Copyright © 2019 akiho. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class NotificationSettingViewController: UITableViewController {
    
    static func instantiate() -> NotificationSettingViewController {
        return R.storyboard.notificationSetting.notificationSettingViewController()!
    }

    @IBOutlet private weak var settingSwitch: UISwitch!
    @IBOutlet private weak var chatSettingSwitch: UISwitch!
    @IBOutlet private weak var bookingRemindSwitch: UISwitch!
    @IBOutlet private weak var backButton: UIBarButtonItem!
    
    private let disposeBag = DisposeBag()
    private var settingIsOn: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
    }
    
    private func bind() {
        let vm = NotificationSettingViewModel(dependency: .init(
            userUseCase: DomainAssembly.injectUserUseCase(),
            notificationSettingUseCase: DomainAssembly.injectNotificationSettingUseCase()
        ))
        
        let output = vm.transform(input: .init(
            viewWillAppear: rx.viewWillAppear.asDriver(),
            didChangeSetting: settingSwitch.rx.isOn.asDriver().skip(1),
            didChangeChatSetting: chatSettingSwitch.rx.isOn.asDriver().skip(1),
            didChangeBookingRemindSetting: bookingRemindSwitch.rx.isOn.asDriver().skip(1)
        ))
        
        output.setting
            .drive(onNext: { [weak self] state in
                self?.settingSwitch.isOn = state.isOn
                self?.settingIsOn = state.isOn
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        output.eachSettings
            .drive(onNext: { [weak self] settings in
                settings.forEach {
                    switch $0.topic {
                    case .chat:
                        self?.chatSettingSwitch.isOn = $0.isOn
                    case .bookingRemind:
                        self?.bookingRemindSwitch.isOn = $0.isOn
                    default:
                        break
                    }
                }
            })
            .disposed(by: disposeBag)
        
        output.isNeedReAuthorization
            .filter { $0 }
            .drive(onNext: { [weak self] isNeed in
                let alertViewController = AlertControllerBuilder
                    .makeBuilder(
                        title: "通知を許可してください",
                        message: "設定画面から通知を許可してください",
                        preferedStyle: .alert
                    )
                    .addAction(title: "閉じる", style: .default, handler: nil)
                    .addAction(title: "許可する", style: .default, handler: { _ in
                        let url = StaticConfig.settingURL
                        guard UIApplication.shared.canOpenURL(url) else {
                            return
                        }
                        UIApplication.shared.open(url)
                    })
                    .build()
                self?.present(alertViewController, animated: true)
            })
            .disposed(by: disposeBag)
        
        output.error
            .drive(onNext: { [weak self] in
                self?.showAlert(with: $0)
            })
            .disposed(by: disposeBag)
        
        backButton.rx.tap.asDriver()
            .drive(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return settingIsOn ? 2 : 0
        default:
            return 1
        }
    }
}
