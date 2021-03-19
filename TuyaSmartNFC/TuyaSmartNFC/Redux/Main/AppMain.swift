//
//  AppMain.swift
//  TuyaSmartNFC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import Foundation
import ReSwift
import ReSwiftThunk

final class AppMain {
    let store: AppStore
    
    init(store: Store<AppState> = makeStore()) {
        self.store = AppStore(store)
    }
}

private func makeStore() -> Store<AppState> {
    .init(
        reducer: AppReducer.reducer,
        state: .init(),
        middleware: [
            createLoggingMiddleware(),
            createThunkMiddleware(),
        ]
    )
}
