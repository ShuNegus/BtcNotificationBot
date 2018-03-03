import Foundation
import TelegramBot

let token = readToken(from: "HELLO_BOT_TOKEN")
let bot = TelegramBot(token: token)

while let update = bot.nextUpdateSync() {
    if let message = update.message, let from = message.from, let text = message.text {
        bot.sendMessageAsync(chat_id: from.id,
                             text: "Hi \(from.first_name)! You said: \(text).\n")
    }
}

fatalError("Server stopped due to error: \(bot.lastError)")
