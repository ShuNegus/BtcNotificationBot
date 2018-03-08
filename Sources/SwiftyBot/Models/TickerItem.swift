//
//  TickerItem.swift
//  SwiftyBot
//
//  Created by Vladimir Shutov on 08.03.2018.
//

import Foundation

struct TickerItem {
    var eventType: String
    var symbol: String
    var priceChange: Double
    var priceChangePercent: Double
    var weightedAveragePrice: Double
    var bestBidPrice: Double
    var bestAskPrice: Double
    var openPrice: Double
    var highPrice: Double
    var lowPrice: Double
    
    init?(json: [String: Any]) {
        guard
            let eventType = json["e"] as? String,
            let symbol = json["s"] as? String,
            let priceChange = (json["p"] as? String)?.toDouble,
            let priceChangePercent = (json["P"] as? String)?.toDouble,
            let weightedAveragePrice = (json["w"] as? String)?.toDouble,
            let bestBidPrice = (json["b"] as? String)?.toDouble,
            let bestAskPrice = (json["a"] as? String)?.toDouble,
            let openPrice = (json["o"] as? String)?.toDouble,
            let highPrice = (json["h"] as? String)?.toDouble,
            let lowPrice = (json["l"] as? String)?.toDouble
            else {
                return nil
        }
        
        self.eventType = eventType
        self.symbol = symbol
        self.priceChange = priceChange
        self.priceChangePercent = priceChangePercent
        self.weightedAveragePrice = weightedAveragePrice
        self.bestBidPrice = bestBidPrice
        self.bestAskPrice = bestAskPrice
        self.openPrice = openPrice
        self.highPrice = highPrice
        self.lowPrice = lowPrice
        
    }
}

extension TickerItem: Equatable {
    
    static func ==(lhs: TickerItem, rhs: TickerItem) -> Bool {
        return lhs.symbol == rhs.symbol
    }
}
