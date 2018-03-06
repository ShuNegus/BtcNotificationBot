//
//  TelegramUser.swift
//  SwiftyBot
//
//  Created by Vladimir Shutov on 07.03.2018.
//

import Foundation

struct TelegramUser {
    var id: UInt64
    var chatId: UInt64
    var firstName: String?
    var lastName: String?
    var username: String?
    var languageCode: String?
}
