//
//  DeviceAction.swift
//  TuyaSmartNFC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import Foundation
import ReSwift
import ReSwiftThunk
import TuyaSmartDeviceKit


class DeviceService: NSObject {
    
    static let shared = DeviceService()
    
    /// fetch Devices
    func fetchDevices(with home: TuyaSmartHome , completion: @escaping ServiceCompletion = { _ in }) {
        home.getDetailWithSuccess({ (homeModel) in
            completion(.success(homeModel));
        }, failure: { (error) in
            print("get home Detail error: \(String(describing: error?.localizedDescription))")
            completion(.failure(error!))
        })
    }
    
    /// delete Device
    func deleteDevice(with device: TuyaSmartDevice, completion: @escaping ServiceCompletion = { _ in }) {
        
        device.remove {
            completion(.success(nil))
        } failure: { error in
            completion(.failure(error!))
        }
    }
}

enum DeviceAction: Action {
    
    case operatorfailed(error: Error)
    case updateDevices(_ devices: [TuyaSmartDeviceModel])
    
    case startDeleteDevice
    
    /// fetch Devices
    static func fetchDevices() -> AppThunkAction {
        AppThunkAction { dispatch, getState in
            
            guard let home = getState()?.homeState.currentHome else { return }
            
            DeviceService.shared.fetchDevices(with: home) { result in
                switch result {
                case .success(_):
                    dispatch(DeviceAction.updateDevices(home.deviceList))
                    break
                case .failure(let error):
                    dispatch(DeviceAction.operatorfailed(error: error))
                    break
                }
            }
        }
    }
    
    
    /// delete Device
    static func delete(with devId: String) -> AppThunkAction {
        AppThunkAction { dispatch, getState in
            
            if var devices = getState()?.deviceState.devices,
               let device = TuyaSmartDevice.init(deviceId: devId) {
                dispatch(DeviceAction.startDeleteDevice)
                DeviceService.shared.deleteDevice(with: device) { result in
                    switch result {
                    case .success(_):
                        let idx = devices.firstIndex(where: {$0.devId == devId})
                        devices.remove(at: idx!)
                        dispatch(DeviceAction.updateDevices(devices))
                        break
                    case .failure(let error):
                        dispatch(DeviceAction.operatorfailed(error: error))
                        break
                    }
                }
            }
        }
    }
    
    
    static func subscribe() -> AppThunkAction {
        AppThunkAction { dispatch, getState in
            dispatch(DeviceAction.fetchDevices())
        }
    }
}
