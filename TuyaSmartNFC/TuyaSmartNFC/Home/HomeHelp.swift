//
//  HomeHelp.swift
//  TuyaSmartNFC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import UIKit
import SwiftUI
import Foundation
import TuyaSmartDeviceKit

class HomeHelp: ObservableObject {
    
    private static var shared = HomeHelp()

    private let homeManager = TuyaSmartHomeManager()
    
    var currentHome: TuyaSmartHome?
    @Published var devices: [TuyaSmartDeviceModel]? = []

    static func loginOut() {
        TuyaSmartUser.sharedInstance().loginOut {

            if let window = UIApplication.shared.windows.first {
                window.rootViewController = UIHostingController(rootView: LoginView())
                window.endEditing(true)
                window.makeKeyAndVisible()
            }
        } failure: { (error) in
            print("login out error: \(String(describing: error?.localizedDescription))")
        }
    }

    /// get first Home
    func initiateCurrentHome() {
//        homeManager.delegate = self
        homeManager.getHomeList { (homeModels) in
            guard let home = homeModels?.first else {
                let homeId = self.createHome()
                self.configCurrentHome(homeId)
                return
            }
            self.configCurrentHome(home.homeId)
        } failure: { (error) in
            print("fetch home list error: \(String(describing: error?.localizedDescription))")
        }
    }

    /// create home
    func createHome() -> Int64 {
        var id: Int64 = 0
        homeManager.addHome(withName: "Zsy's Home", geoName: "Zsy", rooms: ["Bedroom"], latitude: 0, longitude: 0) { (homeId) in
            guard (homeId != 0) else { return }
            id = Int64(Int(homeId))
        } failure: { (error) in
            print("create home error: \(String(describing: error?.localizedDescription))")
        }
        return Int64(id)
    }
    
    /// fetch home Detail
    func configCurrentHome(_ homeId: Int64) {
        self.currentHome = TuyaSmartHome(homeId: homeId)
//        self.currentHome?.delegate = self
        
        self.currentHome?.getDetailWithSuccess({ (homeModel) in
            
            self.devices = self.currentHome?.deviceList
            
        }, failure: { (error) in
            print("get home Detail error: \(String(describing: error?.localizedDescription))")
        })

    }
}
