//
//  ObserverBTC.swift
//  SwiftyBot
//
//  Created by Vladimir Shutov on 08.03.2018.
//

import Foundation

protocol ObserverBTC {
    func tickersChanged(_ tickers: [TickerItem])
    func socketConected()
    func socketClose()
}

class ObserverBTCImpl: ObserverBTC {
    
    var telegramUser: TelegramUser
    var procent: Int
    
    var startTickers: [TickerItem]?
    var symbolsNotified: [String] = []
    
    init(telegramUser: TelegramUser, procent: Int) {
        self.telegramUser = telegramUser
        self.procent = procent
    }
    
    // MARK: - ObserverBTC
    
    func tickersChanged(_ tickers: [TickerItem]) {
        let tickers = tickers.filter({ $0.symbol.contains("BTC") && $0.priceChangePercent <= 5 })
        if let startTickers = self.startTickers {
            compareStartTickers(startTickers, with: tickers)
        } else {
            startTickers = tickers
        }
    }
    
    func socketConected() {
        TelegramMethods().sendMessage("Соединение восстановлено 👍", to: telegramUser.chatId)
    }
    
    func socketClose() {
        TelegramMethods().sendMessage("Перестал следить. Сокеты сломались 😱", to: telegramUser.chatId)
    }
    
    private func compareStartTickers(_ startTickers: [TickerItem], with tickers: [TickerItem]) {
        startTickers.forEach() { [weak self] oldTicker in
            guard
                let `self` = self,
                !symbolsNotified.contains(oldTicker.symbol),
                let ticker = tickers.filter({ $0 == oldTicker }).first else {
                return
            }

            let changeProcent = ticker.priceChangePercent - oldTicker.priceChangePercent
            if self.procent > 0, changeProcent >= Double(self.procent) {
                TelegramMethods().sendMessage("Монетка \(ticker.symbol) поднялась на \(changeProcent)%\nБыло \(oldTicker.priceChangePercent)% стало \(ticker.priceChangePercent)%", to: self.telegramUser.chatId)
                symbolsNotified.append(ticker.symbol)
            } else if self.procent < 0, changeProcent <= Double(self.procent) {
                TelegramMethods().sendMessage("Монетка \(ticker.symbol) упала на \(changeProcent)%\nБыло \(oldTicker.priceChangePercent)% стало \(ticker.priceChangePercent)%", to: self.telegramUser.chatId)
                symbolsNotified.append(ticker.symbol)
            }
        }
    }
    
}
