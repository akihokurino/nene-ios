//
//  SubscriptionUseCase.swift
//  Nene
//
//  Created by akiho on 2019/01/26.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol SubscriptionUseCase {
    func getSubscriptionState(userID: UserID) -> Single<SubscriptionState>
    func getAllPlans() -> Single<[Plan]>
    func getAllSubscriptions() -> Single<[Subscription]>
    func subscribe(userID: UserID, planId: String, params: CardParams) -> Single<SubscriptionState>
    func cancel(userID: UserID) -> Single<SubscriptionState>
}

struct CardParams {
    let number: String
    let exp: String
    let cvc: String
    
    var expMonth: Int {
        let splited = exp.split(separator: "/")
        if splited.count != 2 {
            return 0
        }
        
        return Int(splited[0]) ?? 0
    }
    
    var expYear: Int {
        let splited = exp.split(separator: "/")
        if splited.count != 2 {
            return 0
        }
        
        return Int(splited[1]) ?? 0
    }
}

final class SubscriptionUseCaseImpl: SubscriptionUseCase {
    
    private let userRepository: UserRepository
    private let planRepository: PlanRepository
    private let subscriptionRepository: SubscriptionRepository
    private let cardRepository: CardRepository
    private let customerRepository: CustomerRepository
    
    private var subscriptionState: SubscriptionState?
    
    init(userRepository: UserRepository,
         planRepository: PlanRepository,
         subscriptionRepository: SubscriptionRepository,
         cardRepository: CardRepository,
         customerRepository: CustomerRepository) {
        self.userRepository = userRepository
        self.planRepository = planRepository
        self.subscriptionRepository = subscriptionRepository
        self.cardRepository = cardRepository
        self.customerRepository = customerRepository
    }
    
    func getSubscriptionState(userID: UserID) -> Single<SubscriptionState> {
        if let state = subscriptionState {
            return Single.just(state)
        }
        
        let userRepository = self.userRepository
        
        return Single.just(userID)
            .flatMap { userID -> Single<SubscriptionState> in
                return userRepository.getSubscriptionState(userID: userID)
            }
            .do(onSuccess: { [weak self] state in
                self?.subscriptionState = state
            })
    }
 
    func getAllPlans() -> Single<[Plan]> {
        return planRepository.getAll()
    }
    
    func getAllSubscriptions() -> Single<[Subscription]> {
        return subscriptionRepository.getAll()
    }
    
    func subscribe(userID: UserID, planId: String, params: CardParams) -> Single<SubscriptionState> {
        let subscriptionRepository = self.subscriptionRepository
        let customerRepository = self.customerRepository
        let cardRepository = self.cardRepository
        let card = Card(id: "", expMonth: params.expMonth, expYear: params.expYear, number: params.number, cvc: params.cvc)
        
        return userRepository.getSubscriptionState(userID: userID)
            .flatMap { state -> Single<Void> in
                if state.isRegisterCustomer  {
                    return Single.just(())
                } else {
                    return customerRepository.create()
                }
            }
            .flatMap { _ -> Single<Void> in
                return cardRepository.create(card: card)
            }
            .flatMap { _ -> Single<Void> in
                return subscriptionRepository.create(planId: planId)
            }
            .do(onSuccess: { [weak self] in
                self?.subscriptionState = nil
            })
            .flatMap { [weak self] _ -> Single<SubscriptionState> in
                return self?.getSubscriptionState(userID: userID) ?? Single.error(AppError.toNotExistError())
            }
    }
    
    func cancel(userID: UserID) -> Single<SubscriptionState> {
        return subscriptionRepository.cancel()
            .do(onSuccess: { [weak self] in
                self?.subscriptionState = nil
            })
            .flatMap { [weak self] _ -> Single<SubscriptionState> in
                return self?.getSubscriptionState(userID: userID) ?? Single.error(AppError.toNotExistError())
            }
    }
}
