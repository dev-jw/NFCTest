//
//  LoggingMiddleware.swift
//  TuyaSmartNFC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import Foundation
import ReSwift

func createLoggingMiddleware() -> Middleware<AppState> {
return { _, _ in
    { next in
        { action in
            print("[dispatch]: \(action)")
            next(action)
        }
    }
}
}
