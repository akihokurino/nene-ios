//
//  NotificationAuthorization.swift
//  Nene
//
//  Created by akiho on 2019/02/03.
//  Copyright © 2019 akiho. All rights reserved.
//

import UIKit
import UserNotifications
import RxSwift
import RxCocoa

protocol NotificationAuthorization {
    func request() -> Single<Bool>
    func getSettings() -> Single<UNNotificationSettings>
}

final class NotificationAuthorizationImpl: NotificationAuthorization {
    private let current = UNUserNotificationCenter.current()
    
    func request() -> Single<Bool> {
        let current = self.current
        return Single<Bool>
            .create(subscribe: { observer -> Disposable in
                current.requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { (granted, error) in
                    if let error = error {
                        observer(.error(AppError.toInternalError(error)))
                        return
                    }
                    
                    if granted {
                        DispatchQueue.main.async {
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                    }
                    
                    observer(.success(granted))
                })
            
                return Disposables.create()
            })
    }
    
    func getSettings() -> Single<UNNotificationSettings> {
        let current = self.current
        return Single<UNNotificationSettings>
            .create(subscribe: { observer -> Disposable in
                current.getNotificationSettings(completionHandler: { settings in
                    observer(.success(settings))
                })
                
                return Disposables.create()
            })
    }
}
