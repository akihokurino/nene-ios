//
//  Domain.swift
//  Neon
//
//  Created by akiho on 2019/01/05.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation
import Swinject

final class DomainAssembly: Assembly {
    func assemble(container: Container) {
        container
            .register(UserUseCase.self) { resolver in
                return UserUseCaseImpl(
                    transaction: resolver.resolve(Transaction.self)!,
                    userRepository: resolver.resolve(UserRepository.self)!,
                    notificationSettingRepository: resolver.resolve(NotificationSettingRepository.self)!,
                    customerRepository: resolver.resolve(CustomerRepository.self)!,
                    queuingRepository: resolver.resolve(QueuingRepository.self)!
                )
            }
            .inObjectScope(.container)
        
        container
            .register(ChatRoomUseCase.self) { resolver in
                return ChatRoomUseCaseImpl(
                    transaction: resolver.resolve(Transaction.self)!,
                    userRepository: resolver.resolve(UserRepository.self)!,
                    chatRoomRepository: resolver.resolve(ChatRoomRepository.self)!,
                    messageRepository: resolver.resolve(MessageRepository.self)!,
                    idGenerator: resolver.resolve(IDGenerator.self)!,
                    dynamicConfig: resolver.resolve(DynamicConfig.self)!
                )
            }
            .inObjectScope(.container)
        
        container
            .register(BookingUseCase.self) { resolver in
                return BookingUseCaseImpl(
                    transaction: resolver.resolve(Transaction.self)!,
                    bookingRepository: resolver.resolve(BookingRepository.self)!,
                    messageRepository: resolver.resolve(MessageRepository.self)!,
                    idGenerator: resolver.resolve(IDGenerator.self)!
                )
            }
            .inObjectScope(.container)
    
        container
            .register(NotificationSettingUseCase.self) { resolver in
                return NotificationSettingUseCaseImpl(
                    transaction: resolver.resolve(Transaction.self)!,
                    notificationSettingRepository: resolver.resolve(NotificationSettingRepository.self)!,
                    userRepository: resolver.resolve(UserRepository.self)!,
                    notificationAuthorization: resolver.resolve(NotificationAuthorization.self)!
                )
            }
            .inObjectScope(.container)
        
        container
            .register(SubscriptionUseCase.self) { resolver in
                return SubscriptionUseCaseImpl(
                    userRepository: resolver.resolve(UserRepository.self)!,
                    planRepository: resolver.resolve(PlanRepository.self)!,
                    subscriptionRepository: resolver.resolve(SubscriptionRepository.self)!,
                    cardRepository: resolver.resolve(CardRepository.self)!,
                    customerRepository: resolver.resolve(CustomerRepository.self)!
                )
            }
            .inObjectScope(.container)
        
        container
            .register(QueuingUseCase.self) { resolver in
                return QueuingUseCaseImpl(
                    queuingRepository: resolver.resolve(QueuingRepository.self)!
                )
            }
            .inObjectScope(.container)
    }
}

extension DomainAssembly {
    static func injectUserUseCase() -> UserUseCase {
        return Container.sharedResolver.resolve(UserUseCase.self)!
    }
    
    static func injectChatRoomUseCase() -> ChatRoomUseCase {
        return Container.sharedResolver.resolve(ChatRoomUseCase.self)!
    }
    
    static func injectBookingUseCase() -> BookingUseCase {
        return Container.sharedResolver.resolve(BookingUseCase.self)!
    }
    
    static func injectNotificationSettingUseCase() -> NotificationSettingUseCase {
        return Container.sharedResolver.resolve(NotificationSettingUseCase.self)!
    }
    
    static func injectSubscriptionUseCase() -> SubscriptionUseCase {
        return Container.sharedResolver.resolve(SubscriptionUseCase.self)!
    }
    
    static func injectQueuingUseCase() -> QueuingUseCase {
        return Container.sharedResolver.resolve(QueuingUseCase.self)!
    }
}
