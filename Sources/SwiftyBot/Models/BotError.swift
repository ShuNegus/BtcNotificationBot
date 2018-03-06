//
//  BotError.swift
//  SwiftyBot
//
//  Created by Vladimir Shutov on 07.03.2018.
//

import Foundation

/// Bot errors enum.
enum BotError: Swift.Error {
    /// Missing Telegram or Messenger secret key in Config/secrets/app.json.
    case missingAppSecrets
    /// Missing URL in Messenger structured message button.
    case missingURL
    /// Missing payload in Messenger structured message button.
    case missingPayload
}
