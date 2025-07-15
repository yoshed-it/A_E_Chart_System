import Foundation
import os.log

/**
 *Defines the different levels of logging available*
 
 Each level has an associated emoji for visual identification in logs.
 */
enum LogLevel: String {
    case debug = "🔍"
    case info = "ℹ️"
    case warning = "⚠️"
    case error = "❌"
    case success = "✅"
}

/**
 *Centralized logging utility for the Pluckr application*
 
 This struct provides a unified logging interface that combines console output
 for debugging with system logging for production. It includes different log
 levels and automatic file/function/line tracking.
 
 ## Features
 - Multiple log levels (debug, info, warning, error, success)
 - Automatic source location tracking
 - Console output in debug builds
 - System logging integration
 - Emoji-based visual identification
 
 ## Usage
 ```swift
 PluckrLogger.info("User signed in successfully")
 PluckrLogger.error("Failed to save data: \(error.localizedDescription)")
 PluckrLogger.success("Operation completed")
 ```
 
 ## Log Levels
 - `debug`: Detailed information for debugging
 - `info`: General information about app state
 - `warning`: Potential issues that don't prevent operation
 - `error`: Errors that affect functionality
 - `success`: Successful operations
 */
struct PluckrLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.pluckr"
    private static let category = "PluckrApp"
    
    private static let systemLogger = os.Logger(subsystem: subsystem, category: category)
    
    /**
     *Logs a message with the specified level and source location*
     
     - Parameter message: The message to log
     - Parameter level: The log level (defaults to .info)
     - Parameter file: Source file name (automatically captured)
     - Parameter function: Function name (automatically captured)
     - Parameter line: Line number (automatically captured)
     - Note: In debug builds, logs are printed to console
     - Note: In production, logs are sent to system logging
     */
    static func log(_ message: String, level: LogLevel = .info, file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        let logMessage = "\(level.rawValue) [\(fileName):\(line)] \(function): \(message)"
        
        #if DEBUG
        print(logMessage)
        #endif
        
        // Use os_log for production logging
        switch level {
        case .debug:
            systemLogger.debug("\(logMessage)")
        case .info:
            systemLogger.info("\(logMessage)")
        case .warning:
            systemLogger.warning("\(logMessage)")
        case .error:
            systemLogger.error("\(logMessage)")
        case .success:
            systemLogger.info("\(logMessage)")
        }
    }
    
    static func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .debug, file: file, function: function, line: line)
    }
    
    static func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .info, file: file, function: function, line: line)
    }
    
    static func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .warning, file: file, function: function, line: line)
    }
    
    static func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .error, file: file, function: function, line: line)
    }
    
    static func success(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .success, file: file, function: function, line: line)
    }
} 
