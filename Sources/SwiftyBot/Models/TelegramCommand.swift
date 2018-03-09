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
    case stop
    case observe(duration: Int, procent: Int) // duration в минутах
    case permanent(step: Int, procent: Int) // step в минутах
    
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
        case "/stop":
            self = .stop
        case "/permanent":
            guard
                components.count == 3,
                let step = components[1].int,
                let procent = components[2].int
                else {
                    return nil
            }
            self = .permanent(step: step, procent: procent)
        default:
            return nil
        }
    }
    
    var commandDescription: String {
        switch self {
        case .start:
            return "/start - Инициализирует бота"
        case .help:
            return "/help - Информация о том как работать с ботом"
        case .stop:
            return "/stop - Остановить все наблюдательные процессы"
        case .observe:
            return "/observe duration procent - Начать наблюдать за биржей duration минут\n" +
                   "уведомить при изменении на procent процентов любой монеты"
        case .permanent:
            return "/permanent step procent - Начать наблюдать за биржей пока не отменят. Сбрасывать эталон каждые step минут\n уведомить при изменении на procent процентов любой монеты"
        }
    }

}
