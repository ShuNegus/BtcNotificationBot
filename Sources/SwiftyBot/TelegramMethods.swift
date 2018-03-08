//
//  TelegramMethods.swift
//  SwiftyBot
//
//  Created by Vladimir Shutov on 07.03.2018.
//

import Vapor
import HTTP

class TelegramMethods {
    
    static let shared = TelegramMethods()
    
    var baseTelegramApiUrl = "https://api.telegram.org"
    
    func sendMessage(_ message: String, to chatId: Int) {
        guard let telegramSecret = droplet.config["app", "telegram", "secret"]?.string else {
            droplet.console.error("Missing secret or token keys!")
            droplet.console.error("Add almost one in Config/secrets/app.json")
            return
        }
        let commandUrl = baseTelegramApiUrl + "/" + telegramSecret + "/sendMessage"
        
        do {
            let body = try JSON(node: [
                "chat_id": chatId,
                "text": "response"
                ]).makeBody()
            
            _ = try droplet.client.post(commandUrl, query: [:], ["Content-Type": "application/json"], body, through: [])
            
        } catch let error {
            droplet.console.error("SendMessage Error")
            droplet.console.error(error.localizedDescription)
        }
        
    }
}
