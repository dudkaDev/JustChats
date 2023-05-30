//
//  Message.swift
//  JustChats
//
//  Created by Андрей Абакумов on 23.05.2023.
//

import Foundation
import Firebase
import MessageKit

struct Message: Equatable {
    
    var id: String
    var content: String
    var created: Timestamp
    var senderID: String
    var senderName: String
    
    var dictionary: [String: Any] {
        return [
            "id": id,
            "content": content,
            "created": created,
            "senderID": senderID,
            "senderName":senderName]
    }
}

extension Message {
    
    init?(dictionary: [String: Any]) {
        guard let id = dictionary["id"] as? String,
              let content = dictionary["content"] as? String,
              let created = dictionary["created"] as? Timestamp,
              let senderID = dictionary["senderID"] as? String,
              let senderName = dictionary["senderName"] as? String
        else { return nil }
        self.init(id: id, content: content, created: created, senderID: senderID, senderName:senderName)
    }
    
    init?(document: QueryDocumentSnapshot) {
        
        guard let id = document.data()["id"] as? String,
              let content = document.data()["content"] as? String,
              let created = document.data()["created"] as? Timestamp,
              let senderID = document.data()["senderID"] as? String,
              let senderName = document.data()["senderName"] as? String
        else { return nil }
        
        self.id = id
        self.content = content
        self.senderID = senderID
        self.created = created
        self.senderName = senderName
    }
}

extension Message: MessageType {
    
    var sender: SenderType {
        return ChatUser(senderId: senderID, displayName: senderName)
    }
    
    var messageId: String {
        return id
    }
    
    var sentDate: Date {
        return created.dateValue()
    }
    
    var kind: MessageKind {
        return .text(content)
    }
}

extension Message: Comparable {
    static func < (lhs: Message, rhs: Message) -> Bool {
        return lhs.sentDate < rhs.sentDate
    }
}
