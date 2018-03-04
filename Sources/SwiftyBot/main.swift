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

// MARK: - Errors

/// Bot errors enum.
enum BotError: Swift.Error {
    /// Missing Telegram or Messenger secret key in Config/secrets/app.json.
    case missingAppSecrets
    /// Missing URL in Messenger structured message button.
    case missingURL
    /// Missing payload in Messenger structured message button.
    case missingPayload
}

// MARK: - Configuration

/// Create the Droplet.
let droplet: Droplet = try Droplet()

/// Read Telegram & Messenger secrets key from Config/secrets/app.json.
let telegramSecret = droplet.config["app", "telegram", "secret"]?.string ?? ""
let messengerSecret = droplet.config["app", "messenger", "secret"]?.string ?? ""
let messengerToken = droplet.config["app", "messenger", "token"]?.string ?? ""

guard telegramSecret != "" || (messengerSecret != "" && messengerToken != "") else {
    /// Show errors in console.
    droplet.console.error("Missing secret or token keys!")
    droplet.console.error("Add almost one in Config/secrets/app.json")

    /// Throw missing secret key error.
    throw BotError.missingAppSecrets
}

// MARK: - Helpers

/// Detector String extension.
extension String {
    /// Detect if the message has greetings.
    ///
    /// - Returns: Returns true if the message has greetings, otherwise false.
    func hasGreetings() -> Bool {
        let message = self.lowercased()
        if message.contains("hi") ||
           message.contains("hello") ||
           message.contains("hey") ||
           message.contains("hei") ||
           message.contains("ciao") {
            return true
        }
        return false
    }
}

// MARK: - Telegram bot

/// Setting up the POST request with Telegram secret key.
/// With a secret path to be sure that nobody else knows that URL.
/// https://core.telegram.org/bots/api#setwebhook

droplet.get("info") { _ in
    return "SwiftyBot did start"
}

droplet.post(telegramSecret) { request in
    
    print("request \(request)")
    
    /// Let's prepare the response message text.
    var response: String = ""

    /// Chat ID from request JSON.
    let chatID: Int = request.data["message", "chat", "id"]?.int ?? 0
    /// Message text from request JSON.
    let message: String = request.data["message", "text"]?.string ?? ""
    /// User first name from request JSON.
    let userFirstName: String = request.data["message", "from", "first_name"]?.string ?? ""

    /// Check if the message is empty.
    if message.isEmpty {
        /// Set the response message text.
        response = "I'm sorry but your message is empty 😢"
    /// The message is not empty.
    } else {
        /// Check if the message is a Telegram command.
        if message.hasPrefix("/") {
            /// Check what type of command is.
            switch message {
            /// Start command "/start".
            case "/start":
                /// Set the response message text.
                response = "Welcome to SwiftyBot " + userFirstName + "!\n" +
                           "To list all available commands type /help"
            /// Help command "/help".
            case "/help":
                /// Set the response message text.
                response = "Welcome to SwiftyBot " +
                           "an example on how to create a Telegram bot with Swift using Vapor.\n" +
                           "https://www.fabriziobrancati.com/SwiftyBot\n\n" +
                           "/start - Welcome message\n" +
                           "/help - Help message\n" +
                           "Any text - Returns the reversed message"
            /// Command not valid.
            default:
                /// Set the response message text and suggest to type "/help".
                response = "Unrecognized command.\n" +
                           "To list all available commands type /help"
            }
        /// It is not a Telegram command, so create a reversed message text.
        } else {
            /// Set the response message text.
            response = message.reversed(preserveFormat: true)
        }
    }

    /// Create the JSON response.
    /// https://core.telegram.org/bots/api#sendmessage
    return try JSON(node: [
            "method": "sendMessage",
            "chat_id": chatID,
            "text": response
        ]
    )
}

// MARK: - Messenger bot

/// Struct to help with Messenger messages.
struct Messenger {
    /// Creates a standard Messenger message.
    ///
    /// - Parameter message: Message text to be sent.
    /// - Returns: Returns the created Node ready to be sent.
    static func message(_ message: String) -> Node {
        /// Create the Node.
        return [
            "text": message.makeNode(in: nil)
        ]
    }

    /// Creates a structured Messenger message.
    ///
    /// - Parameter elements: Elements of the structured message.
    /// - Returns: Returns the representable Node.
    /// - Throws: Throws NodeError errors.
    static func structuredMessage(elements: [Element]) throws -> Node {
        /// Create the Node.
        return try ["attachment":
            ["type": "template",
             "payload":
                ["template_type": "generic",
                 "elements": elements.makeNode(in: nil)
                ]
            ]
        ]
    }

    /// Messenger structured message element.
    struct Element: NodeRepresentable {
        /// Element title.
        var title: String
        /// Element subtitle.
        var subtitle: String
        /// Element item URL.
        var itemURL: String
        /// Element image URL.
        var imageURL: String
        /// Element Button array.
        var buttons: [Button]

        /// Element conforms to NodeRepresentable, turn the convertible into a node.
        ///
        /// - Parameter context: Context beyond Node.
        /// - Returns: Returns the Element Node representation.
        /// - Throws: Throws NodeError errors.
        public func makeNode(in context: Context?) throws -> Node {
            /// Create the Node.
            return try Node(node: [
                "title": title.makeNode(in: nil),
                "subtitle": subtitle.makeNode(in: nil),
                "item_url": itemURL.makeNode(in: nil),
                "image_url": imageURL.makeNode(in: nil),
                "buttons": buttons.makeNode(in: nil)
                ]
            )
        }

        /// Button of Messenger structured message element.
        struct Button: NodeRepresentable {
            /// Button type of Messenger structured message element.
            ///
            /// - webURL: Web URL type.
            /// - postback: Postback type.
            enum `Type`: String {
                case webURL = "web_url"
                case postback = "postback"
            }

            /// Set all its property to get only.
            /// https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/AccessControl.html#//apple_ref/doc/uid/TP40014097-CH41-ID18
            /// Button type.
            private(set) var type: Type
            /// Button title.
            private(set) var title: String
            /// Button payload, postback type only.
            private(set) var payload: String?
            /// Button URL, webURL type only.
            private(set) var url: String?

            /// Creates a Button for Messenger structured message element.
            ///
            /// - Parameters:
            ///   - type: Button type.
            ///   - title: Button title.
            ///   - payload: Button payload.
            ///   - url: Button URL.
            /// - Throws: Throws NodeError errors.
            init(type: Type, title: String, payload: String? = nil, url: String? = nil) throws {
                /// Set Button type.
                self.type = type
                /// Set Button title.
                self.title = title

                /// Check what Button type is.
                switch type {
                /// Is a webURL type, so se its url.
                case .webURL:
                    /// Check if url is nil.
                    guard let url = url else {
                        throw BotError.missingURL
                    }
                    self.url = url
                /// Is a postback type, so se its payload.
                case .postback:
                    /// Check if payload is nil.
                    guard let payload = payload else {
                        throw BotError.missingPayload
                    }
                    self.payload = payload
                }
            }

            /// Button conforms to NodeRepresentable, turn the convertible into a node.
            ///
            /// - Parameter context: Context beyond Node.
            /// - Returns: Returns the Button Node representation.
            /// - Throws: Throws NodeError errors.
            public func makeNode(in context: Context?) throws -> Node {
                /// Create the Node with type and title.
                var node: Node = [
                    "type": type.rawValue.makeNode(in: nil),
                    "title": title.makeNode(in: nil)
                ]

                /// Extends the Node with url or payload, depends on Button type.
                switch type {
                /// Extends with url property.
                case .webURL:
                    node["url"] = url?.makeNode(in: nil) ?? ""
                /// Extends with payload property.
                case .postback:
                    node["payload"] = payload?.makeNode(in: nil) ?? ""
                }

                /// Create the Node.
                return Node(node: node)
            }
        }
    }
}

// MARK: - Droplet run

/// Run the Droplet.
try droplet.run()
