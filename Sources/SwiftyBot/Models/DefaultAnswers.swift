//
//  DefaultAnswers.swift
//  SwiftyBot
//
//  Created by Vladimir Shutov on 07.03.2018.
//

import Foundation

struct DefaultAnswers {
    
    func startAnswers(userName: String) -> String {
        return "Привет \(userName)! Я помогу тебе следить за биржей www.binance.com"
    }
    
    func helpAnswers() -> String {
        return TelegramCommand.start.commandDescription + "\n" +
                TelegramCommand.help.commandDescription + "\n" +
                TelegramCommand.stop.commandDescription + "\n" +
                TelegramCommand.permanent(step: 0, procent: 0).commandDescription + "\n" +
                TelegramCommand.observe(duration: 0, procent: 0).commandDescription
    }
    
    func startObserveAnswers(duration: Int, procent: Int) -> String {
        return
"""
Буду следить за курсом в течении \(duration) минут.
Сообщу если курс любой монетки \(procent > 0 ? "увеличится" : "уменьшится") на \(abs(procent))%
"""
    }
    
    func startObserveErrorAnswers() -> String {
        return "Не могу начать следить. Проверь исходные данные."
    }
    
    func permanentObserveAnswers(step: Int, procent: Int) -> String {
        return
"""
Буду следить за курсом пока не остановишь.
Буду сбрасывать эталон сравнения каждые \(step) минут
Сообщу если курс любой монетки \(procent > 0 ? "увеличится" : "уменьшится") на \(abs(procent))%
"""
    }
    
    func stopAnswer() -> String {
        return "Не слежу не за чем"
    }
    
}
