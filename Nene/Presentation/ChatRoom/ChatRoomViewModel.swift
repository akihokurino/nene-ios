//
//  ChatRoomViewModel.swift
//  Neon
//
//  Created by akiho on 2019/01/05.
//  Copyright © 2019 akiho. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ChatRoomViewModel: InjectableViewModel {
   
    struct Dependency {
        let userUseCase: UserUseCase
        let chatRoomUseCase: ChatRoomUseCase
        let subscriptionUseCase: SubscriptionUseCase
    }
    
    struct Input {
        let didInputText: Driver<String>
        let didTapSendButton: Driver<Void>
        let reachedBottom: Driver<Void>
        let viewWillAppear: Driver<Void>
    }
    
    struct Output {
        let messages: Driver<[Message]>
        let didSendMessage: Driver<Void>
        let error: Driver<Error>
        let initLoading: Driver<Bool>
        let checkEnable: Driver<Bool>
    }
    
    private let userUseCase: UserUseCase
    private let chatRoomUseCase: ChatRoomUseCase
    private let subscriptionUseCase: SubscriptionUseCase
    
    init(dependency: Dependency) {
        self.userUseCase = dependency.userUseCase
        self.chatRoomUseCase = dependency.chatRoomUseCase
        self.subscriptionUseCase = dependency.subscriptionUseCase
    }
    
    func transform(input: Input) -> Output {
        let userUseCase = self.userUseCase
        let chatRoomUseCase = self.chatRoomUseCase
        let subscriptionUseCase = self.subscriptionUseCase
        
        let meAction = Driver.just(())
            .flatMap { _ -> Driver<Action<User>> in
                let source = userUseCase.me()
                return Action.makeDriver(source)
            }
        
        let getSubscriptionStateAction = Driver.merge(
            meAction.elements,
            input.viewWillAppear.withLatestFrom(meAction.elements))
            .flatMap { user -> Driver<Action<SubscriptionState?>> in
                let source = subscriptionUseCase.getSubscriptionState(userID: user.toUserID)
                    .map { Optional($0) }
                    .catchErrorJustReturn(nil)
                return Action.makeDriver(source)
            }
        
        let checkEnable = Driver.combineLatest(meAction.elements, getSubscriptionStateAction.elements)
            .flatMap { user, subscriptionState -> Driver<Bool> in
                return chatRoomUseCase.checkEnabled(
                    me: user,
                    subscriptionState: subscriptionState,
                    now: Date())
            }
        
        let initChatRoomAction = meAction.elements
            .flatMap { user -> Driver<Action<ChatRoom>> in
                let source = chatRoomUseCase.initRoom(userID: user.toUserID, now: Date())
                return Action.makeDriver(source)
            }
        
        let syncMessageAction = initChatRoomAction.elements
            .withLatestFrom(meAction.elements)
            .flatMap { user -> Driver<Action<[Message]>> in
                let source = chatRoomUseCase.syncMessage(userID: user.toUserID)
                return Action.makeDriver(source)
            }
        
        let isSending: BehaviorRelay<Bool> = BehaviorRelay(value: false)
        
        let sendTextAction = input.didTapSendButton
            .filter { !isSending.value }
            .do(onNext: { isSending.accept(true) })
            .withLatestFrom(input.didInputText.filter { !$0.isEmpty })
            .withLatestFrom(meAction.elements) { ($0, $1) }
            .withLatestFrom(checkEnable) { ($0, $1) }
            .flatMap { pair, isEnabled -> Driver<Action<Void>> in
                guard isEnabled else {
                    return Action.makeDriver(Single.error(AppError.toExpireFreePlan()))
                }
                let source = chatRoomUseCase.sendMessage(userID: pair.1.toUserID, text: pair.0, now: Date())
                return Action.makeDriver(source)
            }
        
        let messages = Driver.merge(syncMessageAction.elements)
        let didSendMessage = sendTextAction.elements.do(onNext: { isSending.accept(false) })
        let error = Driver.merge(
            meAction.error,
            sendTextAction.error.do(onNext: { _ in isSending.accept(false) }),
            syncMessageAction.error)
        let initLoading = initChatRoomAction.isExecuting
        
        return Output(messages: messages,
                      didSendMessage: didSendMessage,
                      error: error,
                      initLoading: initLoading,
                      checkEnable: checkEnable)
    }
}

