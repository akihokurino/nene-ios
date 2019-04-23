//
//  Message.swift
//  Neon
//
//  Created by akiho on 2019/01/06.
//  Copyright © 2019 akiho. All rights reserved.
//

import Foundation
import RxSwift
import Firebase

struct Message {
    let id: String
    let fromUserID: UserID
    let toUserID: UserID
    let text: String
    let imageURL: URL?
    let createdAt: Date
    let isMine: Bool

    func toMyMessageIfNeed(myID: UserID) -> Message {
        if fromUserID.id == myID.id {
            return Message(id: id,
                           fromUserID: fromUserID,
                           toUserID: toUserID,
                           text: text,
                           imageURL: imageURL,
                           createdAt: createdAt,
                           isMine: true)
        }
        
        return self
    }
    
    static func firstSystemMessage(id: String, myID: UserID, now: Date) -> Message {
        let text = "登録ありがとうございます！\nはじめまして！オンライン秘書サービスのnene（ネネ）と申します。\nご登録者様の代わりに、\n✔︎お店の予約\n✔︎ホテルの予約\n✔︎贈り物選び\n✔︎電話代行（美容院の代行予約　等）\nなど、日頃から面倒だなと感じていた事を対応いたします！今回は招待者限定特典として、15日間無料でneneを利用することができます！\n\n例えば、\n「渋谷 明日 18時から 5名で会食を予約したい」\n「明日、美容院予約しておいて！」\n\nと、気軽にご依頼ください！\n※一部対応できない場合がございます、あらかじめご了承ください。"
        
        return Message(id: id,
                       fromUserID: StaticConfig.adminUserID,
                       toUserID: myID,
                       text: text,
                       imageURL: nil,
                       createdAt: now,
                       isMine: false)
    }
}

protocol MessageRepository {
    func observe(chatRoom: ChatRoom) -> Observable<[Message]>
    func create(_ batch: WriteBatch, chatRoom: ChatRoom, message: Message)
}
