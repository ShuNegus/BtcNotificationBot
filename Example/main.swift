//
//  main.swift
//  ZEGBotExample
//
//  Created by Shane Qi on 9/28/17.
//

import ZEGBot
import Foundation

let bot = ZEGBot(token: "547106684:AAH1Izf8ZwxZ5uw7Bw4iHU9frxC1jwN5fgs")

bot.run { updateResult, bot in
    print("bot.run { updateResult, bot in")
    switch updateResult {
    case .success(let update):
        if let message = update.message {
            bot.send(message: "bar", to: message.chat)
        } else {
            print("update.message nop")
        }
    case .failure(let error):
        dump(error)
    }
}

