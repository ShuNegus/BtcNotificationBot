//
//  ObserverBTC.swift
//  SwiftyBot
//
//  Created by Vladimir Shutov on 08.03.2018.
//

import Foundation

protocol ObserverBTC {
    func tickersChanged(_ tickers: [TickerItem])
    func socketClose()
}

class ObserverBTCImpl: ObserverBTC {
    
    var telegramUser: TelegramUser
    var procent: Int
    
    var startTickers: [TickerItem]?
    
    init(telegramUser: TelegramUser, procent: Int) {
        self.telegramUser = telegramUser
        self.procent = procent
    }
    
    // MARK: - ObserverBTC
    
    func tickersChanged(_ tickers: [TickerItem]) {
        let tickers = tickers.filter({ $0.symbol.contains("BTC") })
        if let startTickers = self.startTickers {
            compareStartTickers(startTickers, with: tickers)
        } else {
            startTickers = tickers
        }
    }
    
    func socketClose() {
        TelegramMethods().sendMessage("Перестал следить. Сокеты сломались 😱.\nНужно перезапустить сервер.", to: telegramUser.chatId)
    }
    
    private func compareStartTickers(_ startTickers: [TickerItem], with tickers: [TickerItem]) {
        startTickers.forEach() { [weak self] oldTicker in
            guard
                let `self` = self,
                let ticker = tickers.filter({ $0 == oldTicker }).first else {
                return
            }

            let changeProcent = ticker.priceChangePercent - oldTicker.priceChangePercent
            if self.procent > 0, changeProcent >= Double(self.procent) {
                TelegramMethods().sendMessage("Монетка \(ticker.symbol) поднялась на \(changeProcent)%\nБыло \(oldTicker.priceChangePercent)% стало \(ticker.priceChangePercent)%", to: self.telegramUser.chatId)
            } else if self.procent < 0, -changeProcent <= Double(self.procent) {
                TelegramMethods().sendMessage("Монетка \(ticker.symbol) упала на \(changeProcent)%", to: self.telegramUser.chatId)
            }
        }
    }
    
}
