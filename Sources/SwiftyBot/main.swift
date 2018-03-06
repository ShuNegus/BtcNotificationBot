//
//  main.swift
//  SwiftyBot
//
//  The MIT License (MIT)
//
//  Copyright (c) 2016 - 2018 Fabrizio Brancati.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

/// Import Vapor & BFKit frameworks.
import Vapor
import HTTP
import BFKit
import Dispatch

let droplet: Droplet = try Droplet()

guard let telegramSecret = droplet.config["app", "telegram", "secret"]?.string else {
    droplet.console.error("Missing secret or token keys!")
    droplet.console.error("Add almost one in Config/secrets/app.json")
    throw BotError.missingAppSecrets
}

droplet.get("info") { _ in
  return "SwiftyBot start"
}

droplet.post("telegram", telegramSecret) { request in
    
    guard
        let chatId = request.data["message", "chat", "id"]?.int
        else {
            droplet.console.error("Missing chatId in request")
            throw BotError.missingPayload
    }
    
    guard
        let message = request.data["message", "text"]?.string,
        let command = TelegramCommand(rawValue: message)
        else {
            TelegramMethods().sendMessage(DefaultAnswers().helpAnswers(), to: chatId)
            droplet.console.error("Empty message in request")
            throw BotError.missingPayload
    }
    
    let userFirstName = request.data["message", "from", "first_name"]?.string ?? "Incognito"
    
    var answer = ""
    
    switch command {
    case .start:
        answer = DefaultAnswers().startAnswers(userName: userFirstName)
    case .help:
        answer = DefaultAnswers().helpAnswers()
    case .observe(let duration, let procent):
        answer = DefaultAnswers().startObserveAnswers(duration: duration, procent: procent)
    }
    
    return try JSON(node: [
        "method": "sendMessage",
        "chat_id": chatId,
        "text": answer
        ])
    
}

/// Run the Droplet.
try droplet.run()











