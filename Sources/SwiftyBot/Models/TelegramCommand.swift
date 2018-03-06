//
//  TelegramCommand.swift
//  SwiftyBot
//
//  Created by Vladimir Shutov on 07.03.2018.
//

import Vapor
import HTTP
import BFKit

enum TelegramCommand {
    case start
    case help
    case observe(duration: Int, procent: Int)
    
    init?(rawValue: String) {
        let components = rawValue.components(separatedBy: " ")
        
        switch components[0] {
        case "/start":
            self = .start
        case "/help":
            self = .help
        case "/observe":
            guard
                components.count == 3,
                let duration = components[1].int,
                let procent = components[2].int
                else {
                    return nil
            }
            self = .observe(duration: duration, procent: procent)
        default:
            return nil
        }
    }
    
    var commandDescription: String {
        switch self {
        case .start:
            return "/start - Инициализирует бота"
        case .help:
            return "/help - Информацияо том как работать с ботом"
        case .observe:
            return "/observe duration procent - Начать наблюдать за биржей duration минут/n" +
                   "уведомить при падении на procent процентов любой монеты"
        }
    }

}
