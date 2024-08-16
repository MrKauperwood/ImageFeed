//
//  Logger.swift
//  ImageFeed
//
//  Created by Aleksei Bondarenko on 15.8.2024.
//

import Foundation

class Logger {
    enum LogLevel: String {
        case info = "INFO"
        case warning = "WARNING"
        case error = "ERROR"
    }

    static func logMessage(_ message: String, for object: Any, level: LogLevel = .info) {
        let className: String
        if let stringObject = object as? String {
            className = stringObject
        } else {
            className = String(describing: type(of: object))
        }
        let formattedMessage = "[\(level.rawValue)] [\(className)] - \(message)"
        print(formattedMessage)
    }
}
