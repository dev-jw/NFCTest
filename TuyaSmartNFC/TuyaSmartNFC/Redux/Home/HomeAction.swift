//
//  HomeAction.swift
//  TuyaSmartNFC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import Foundation
import ReSwift
import ReSwiftThunk
import TuyaSmartBaseKit
import TuyaSmartDeviceKit

class HomeService: NSObject {
    
    private let homeManager = TuyaSmartHomeManager()
    
    static let shared = HomeService()
    
    /// get first Home
    func initiateCurrentHome(completion: @escaping ServiceCompletion = { _ in }) {
        homeManager.delegate = self
        homeManager.getHomeList { (homeModels) in
            completion(.success(homeModels ?? [TuyaSmartHomeModel].self))
        } failure: { (error) in
            completion(.failure(error!))
        }
    }
    
    /// create home
    func createHome(completion: @escaping ServiceCompletion = { _ in }) {
        var id: Int64 = 0
        let homeName = "Zsy's Home - \(homeManager.homes.count)"
        homeManager.addHome(withName: homeName,
                            geoName: "Hangzhou",
                            rooms: ["Bedroom"],
                            latitude: 0,
                            longitude: 0) { (homeId) in
            guard (homeId != 0) else { return }
            id = Int64(Int(homeId))
            completion(.success(id))
        } failure: { (error) in
            print("create home error: \(String(describing: error?.localizedDescription))")
            completion(.failure(error!))
        }
    }
    
    /// delete Home
    func deleteHome(with id: Int64, completion: @escaping ServiceCompletion = { _ in }) {
        let home = TuyaSmartHome.init(homeId: id)
        
        home?.dismiss {
            completion(.success(home))
        } failure: { (error) in
            completion(.failure(error!))
        }
    }
    
}

extension HomeService: TuyaSmartHomeManagerDelegate {
    
}


enum HomeAction: Action {
    /// fetch Home List
    case fetchHomeListStarted
    case updateHomes(homes: [TuyaSmartHomeModel])
    case operatorfailed(error: Error)
    
    case updateCurrent(home: TuyaSmartHome)
    
    
    
    
    //    case fetchHomeListFinished
    //    case fetchHomeListFailed(error: Error)
    //
    //    /// create Home
    //    case createHomeStarted
    //    case createHomeFinished
    //    case createHomeFailed(error: Error)
    //
    //    /// delete Home
    //    case deleteHomeStarted
    //    case deleteHomeFinished
    //    case deleteHomeFailed(error: Error)
    //
    
    static func subscribe() -> AppThunkAction {
        AppThunkAction { dispatch, getState in
            
            HomeService.shared.initiateCurrentHome { result in
                switch result {
                case .success(let homes):
                    dispatch(HomeAction.updateHomes(homes: homes as! [TuyaSmartHomeModel]))
                    break
                case .failure(let error):
                    dispatch(HomeAction.operatorfailed(error: error))
                    break
                }
            }
        }
    }
    
    static func create() -> AppThunkAction {
        AppThunkAction { dispatch, getState in
            
            if var homes = getState()?.homeState.homes {
                
                HomeService.shared.createHome { result in
                    switch result {
                    case .success(let homeId):
                        guard let home = TuyaSmartHome(homeId: homeId as! Int64) else {
                            return
                        }
                        homes.append(home.homeModel)
                        dispatch(HomeAction.updateHomes(homes: homes))
                        break
                    case .failure(let error):
                        dispatch(HomeAction.operatorfailed(error: error))
                        break
                    }
                }
            }
        }
    }
    
    static func delete(_ id: Int64) -> AppThunkAction {
        AppThunkAction { dispatch, getState in
            
            if var homes = getState()?.homeState.homes, getState()?.homeState.currentHome?.homeModel.homeId != id {
                
                HomeService.shared.deleteHome(with: id) { result in
                    switch result {
                    case .success(_):
                        let idx = homes.firstIndex(where: {$0.homeId == id})
                        homes.remove(at: idx!)
                        dispatch(HomeAction.updateHomes(homes: homes))
                        break
                    case .failure(let error):
                        dispatch(HomeAction.operatorfailed(error: error))
                        break
                    }
                }
            }
        }
    }
    
    static func switchCurrentHome(_ homeId: Int64) -> AppThunkAction {
        AppThunkAction { dispatch, _ in
            guard let home = TuyaSmartHome(homeId: homeId) else {
                return
            }
            Home.current = home
            dispatch(HomeAction.updateCurrent(home: home))
            dispatch(DeviceAction.fetchDevices())
        }
    }
    
}
