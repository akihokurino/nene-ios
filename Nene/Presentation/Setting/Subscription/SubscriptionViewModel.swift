//
//  SubscriptionViewModel.swift
//  Nene
//
//  Created by akiho on 2019/01/13.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class SubscriptionViewModel: InjectableViewModel {
    
    struct Dependency {
        let userUseCase: UserUseCase
        let subscriptionUseCase: SubscriptionUseCase
    }
    
    struct Input {
        let didInputNumber: Driver<String>
        let didInputExp: Driver<String>
        let didInputCvc: Driver<String>
        let didTapSubscribeButton: Driver<Void>
        let didTapCancelButton: Driver<Void>
    }
    
    struct Output {
        let plans: Driver<[Plan]>
        let subscriptionState: Driver<SubscriptionState>
        let subscriptions: Driver<[Subscription]>
        let isExecuting: Driver<Bool>
        let error: Driver<Error>
    }
    
    private let userUseCase: UserUseCase
    private let subscriptionUseCase: SubscriptionUseCase
    
    init(dependency: Dependency) {
        userUseCase = dependency.userUseCase
        subscriptionUseCase = dependency.subscriptionUseCase
    }
    
    func transform(input: Input) -> Output {
        let userUseCase = self.userUseCase
        let subscriptionUseCase = self.subscriptionUseCase
        
        let meAction = Driver.just(())
            .flatMap { _ -> Driver<Action<User>> in
                let source = userUseCase.me()
                return Action.makeDriver(source)
            }
    
        let getPlanAction = Driver.just(())
            .flatMap { _ -> Driver<Action<[Plan]>> in
                let source = subscriptionUseCase.getAllPlans()
                return Action.makeDriver(source)
            }
        
        let getSubscriptionStateAction = meAction.elements
            .flatMap { user -> Driver<Action<SubscriptionState>> in
                let source = subscriptionUseCase.getSubscriptionState(userID: user.toUserID)
                return Action.makeDriver(source)
            }
        
        let getSubscriptionAction = getSubscriptionStateAction.elements.filter { $0.isSubscribe }
            .flatMap { _ -> Driver<Action<[Subscription]>> in
                let source = subscriptionUseCase.getAllSubscriptions()
                return Action.makeDriver(source)
        }
        
        let inputCard = Driver.combineLatest(
            input.didInputNumber,
            input.didInputExp,
            input.didInputCvc
        ) { number, exp, cvc -> CardParams in
            return CardParams(number: number, exp: exp, cvc: cvc)
        }
        
        let subscribeAction = input.didTapSubscribeButton
            .withLatestFrom(getPlanAction.elements.filter { !$0.isEmpty })
            .withLatestFrom(inputCard) { ($0, $1) }
            .withLatestFrom(meAction.elements) { ($0, $1) }
            .flatMap { pair, user -> Driver<Action<SubscriptionState>> in
                let plan = pair.0.first!
                let source = subscriptionUseCase.subscribe(
                    userID: user.toUserID,
                    planId: plan.id,
                    params: pair.1)
                return Action.makeDriver(source)
            }
        
        let cancelAction = input.didTapCancelButton
            .withLatestFrom(meAction.elements)
            .flatMap { user -> Driver<Action<SubscriptionState>> in
                let source = subscriptionUseCase.cancel(userID: user.toUserID)
                return Action.makeDriver(source)
            }
        
        let plans = getPlanAction.elements
        
        let subscriptionState = Driver.merge(
            getSubscriptionStateAction.elements,
            subscribeAction.elements,
            cancelAction.elements)
        
        let subscriptions = getSubscriptionAction.elements
        
        let isExecuting = Driver.merge(
            getSubscriptionStateAction.isExecuting,
            subscribeAction.isExecuting,
            cancelAction.isExecuting)
        
        let error = Driver.merge(
            meAction.error,
            getPlanAction.error,
            getSubscriptionStateAction.error,
            getSubscriptionAction.error,
            subscribeAction.error,
            cancelAction.error)
        
        return Output(
            plans: plans,
            subscriptionState: subscriptionState,
            subscriptions: subscriptions,
            isExecuting: isExecuting,
            error: error
        )
    }
}
