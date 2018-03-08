//
//  SocketBTC.swift
//  SwiftyBot
//
//  Created by Vladimir Shutov on 08.03.2018.
//

import Foundation
import Vapor
import HTTP

class SocketBTC {
    
    var observers: [ObserverBTC] = []
    
    
    func run() throws {
        try droplet.client
            .socket.connect(to: "wss://stream.binance.com:9443/ws/!ticker@arr") { [weak self] webSocet in
                
                webSocet.onText = { ws, text in
                    let tikersRaw = text.toJSON as? [[String: Any]] ?? []
                    let tikers = tikersRaw.flatMap({ TickerItem(json: $0) })
                    self?.observers.forEach({ $0.tickersChanged(tikers) })
                }
                
                webSocet.onClose = { _, _, _, _ in
                    self?.observers.forEach({ observer in
                        observer.socketClose()
                    })
                }
        }
    }
    
}
