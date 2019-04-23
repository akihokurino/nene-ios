//
//  Infra.swift
//  Neon
//
//  Created by akiho on 2019/01/05.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation
import Swinject
import Firebase

final class InfraAssembly: Assembly {
    func assemble(container: Container) {
        container
            .register(PrimitiveConverter.self) { resolver in
                return PrimitiveConverterImpl()
            }
            .inObjectScope(.container)
        
        container
            .register(Transaction.self) { resolver in
                return TransactionImpl(
                    db: resolver.resolve(Firestore.self)!
                )
            }
            .inObjectScope(.container)
        
        container
            .register(NotificationAuthorization.self) { resolver in
                return NotificationAuthorizationImpl()
            }
            .inObjectScope(.container)
        
        container
            .register(DynamicConfig.self) { resolver in
                return DynamicConfigImpl()
            }
            .inObjectScope(.container)
        
        container
            .register(Firestore.self) { resolver in
                return Firestore.firestore()
            }
            .inObjectScope(.container)
        
        container
            .register(Functions.self) { resolver in
                return Functions.functions()
            }
            .inObjectScope(.container)
        
        container
            .register(UserRepository.self) { resolver in
                return UserRepositoryImpl(
                    db: resolver.resolve(Firestore.self)!,
                    converter: resolver.resolve(PrimitiveConverter.self)!
                )
            }
            .inObjectScope(.container)
        
        container
            .register(ChatRoomRepository.self) { resolver in
                return ChatRoomRepositoryImpl(
                    db: resolver.resolve(Firestore.self)!,
                    converter: resolver.resolve(PrimitiveConverter.self)!
                )
            }
            .inObjectScope(.container)
        
        container
            .register(MessageRepository.self) { resolver in
                return MessageRepositoryImpl(
                    db: resolver.resolve(Firestore.self)!,
                    converter: resolver.resolve(PrimitiveConverter.self)!
                )
            }
            .inObjectScope(.container)
        
        container
            .register(BookingRepository.self) { resolver in
                return BookingRepositoryImpl(
                    db: resolver.resolve(Firestore.self)!,
                    converter: resolver.resolve(PrimitiveConverter.self)!
                )
            }
            .inObjectScope(.container)
        
        container
            .register(NotificationSettingRepository.self) { resolver in
                return NotificationSettingRepositoryImpl(
                    db: resolver.resolve(Firestore.self)!,
                    converter: resolver.resolve(PrimitiveConverter.self)!
                )
            }
            .inObjectScope(.container)
        
        container
            .register(PlanRepository.self) { resolver in
                return PlanRepositoryImpl(
                    functions: resolver.resolve(Functions.self)!,
                    converter: resolver.resolve(PrimitiveConverter.self)!
                )
            }
            .inObjectScope(.container)
        
        container
            .register(SubscriptionRepository.self) { resolver in
                return SubscriptionRepositoryImpl(
                    functions: resolver.resolve(Functions.self)!,
                    converter: resolver.resolve(PrimitiveConverter.self)!
                )
            }
            .inObjectScope(.container)
        
        container
            .register(CustomerRepository.self) { resolver in
                return CustomerRepositoryImpl(
                    functions: resolver.resolve(Functions.self)!,
                    converter: resolver.resolve(PrimitiveConverter.self)!
                )
            }
            .inObjectScope(.container)
        
        container
            .register(CardRepository.self) { resolver in
                return CardRepositoryImpl(
                    functions: resolver.resolve(Functions.self)!,
                    converter: resolver.resolve(PrimitiveConverter.self)!
                )
            }
            .inObjectScope(.container)
        
        container
            .register(QueuingRepository.self) { resolver in
                return QueuingRepositoryImpl(
                    db: resolver.resolve(Firestore.self)!,
                    converter: resolver.resolve(PrimitiveConverter.self)!
                )
            }
            .inObjectScope(.container)
        
        container
            .register(IDGenerator.self) { resolver in
                return IDGeneratorImpl()
            }
            .inObjectScope(.container)
    }
}
