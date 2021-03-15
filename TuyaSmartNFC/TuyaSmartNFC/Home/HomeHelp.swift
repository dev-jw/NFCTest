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
    @Published var currentHome: TuyaSmartHomeModel?
    @Published var devices: [TuyaSmartDeviceModel]? = []
    @Published var homeList: [TuyaSmartHomeModel]? = []

    private var home: TuyaSmartHome? = nil
    
    private let homeManager = TuyaSmartHomeManager()
    
    static let shared = HomeHelp()

    /// get first Home
    func initiateCurrentHome() {
//        homeManager.delegate = self
        homeManager.getHomeList { [self] (homeModels) in
            self.homeList = homeModels
            guard let home = homeModels?.first else {
                let homeId = createHome()
                 configCurrentHome(homeId)
                return
            }
            configCurrentHome(home.homeId)
        } failure: { (error) in
            print("fetch home list error: \(String(describing: error?.localizedDescription))")
        }
    }

    /// create home
    func createHome() -> Int64 {
        var id: Int64 = 0
        let homeName = "Zsy's Home - \(homeManager.homes.count)"
        homeManager.addHome(withName: homeName, geoName: "Hangzhou", rooms: ["Bedroom"], latitude: 0, longitude: 0) { (homeId) in
            guard (homeId != 0) else { return }
            id = Int64(Int(homeId))
        } failure: { (error) in
            print("create home error: \(String(describing: error?.localizedDescription))")
        }
        return Int64(id)
    }
    
    /// setup home
    func configCurrentHome(_ homeId: Int64) {
        home = TuyaSmartHome(homeId: homeId)
        currentHome = home!.homeModel
    }
    
    /// fetch Home Detail
    func fetchDevices() {
        home!.getDetailWithSuccess({ [self] (homeModel) in
            currentHome = homeModel
            devices = home!.deviceList
        }, failure: { (error) in
            print("get home Detail error: \(String(describing: error?.localizedDescription))")
        })
    }
    
    
    // delete Home
    func deleteHome(at offsets: IndexSet) {
        if let first = offsets.first {
            
            let homeModel = homeList![first]
            
            let home = TuyaSmartHome.init(homeId: homeModel.homeId)
            
            home?.dismiss { [self] in
                homeList?.remove(at: first)
            } failure: { (error) in
                print("dismiss home Detail error: \(String(describing: error?.localizedDescription))")
            }
        }
    }
}
