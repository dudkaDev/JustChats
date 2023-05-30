//
//  ChatUser.swift
//  JustChats
//
//  Created by Андрей Абакумов on 23.05.2023.
//

import Foundation
import MessageKit

struct ChatUser: SenderType, Equatable {
    
    var senderId: String
    var displayName: String
}
