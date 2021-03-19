//
//  SignState.swift
//  TuyaSmartNFC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import Foundation
import ReSwift

struct SignState: StateType {
    var requesting: Bool = false
    var error: Error?
}
