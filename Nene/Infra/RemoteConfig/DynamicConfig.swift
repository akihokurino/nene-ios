//
//  DynamicConfig.swift
//  Nene
//
//  Created by akiho on 2019/01/31.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation
import Firebase
import RxSwift
import RxCocoa

protocol DynamicConfig {
    var freeDuration: Driver<Int> { get }
    func load()
}

final class DynamicConfigImpl: DynamicConfig {
    private let keyFreeDuration = "freeDuration"
    private let config: RemoteConfig
    
    private let _freeDuration: BehaviorRelay<Int> = BehaviorRelay(value: 1296000) // 15日
    
    var freeDuration: Driver<Int> {
        return _freeDuration.asDriver(onErrorDriveWith: .empty())
    }
    
    init() {
        config = RemoteConfig.remoteConfig()
        config.configSettings = RemoteConfigSettings(developerModeEnabled: true)
        
        load()
    }
    
    func load() {
        let expirationDuration = config.configSettings.isDeveloperModeEnabled ? 0 : 3600
        config.fetch(withExpirationDuration: TimeInterval(expirationDuration)) { [weak self] (status, error) -> Void in
            guard let self = self else { return }
            
            if status == .success {
                self.config.activateFetched()
            } else {
                // TODO: エラーハンドリング
            }
            
            self._freeDuration.accept(Int(self.config[self.keyFreeDuration].stringValue ?? "") ?? 0)
        }
    }
}
