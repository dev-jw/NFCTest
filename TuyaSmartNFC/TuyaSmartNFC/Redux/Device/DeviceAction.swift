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
    
    private var dispatch: DispatchFunction?
    
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
    
    func publishDps(with device: TuyaSmartDevice, dps: [AnyHashable : Any], dispatch: @escaping DispatchFunction, completion: @escaping ServiceCompletion = { _ in }) {
        
        DeviceService.shared.dispatch = dispatch
        
        device.publishDps(dps) {
            completion(.success(nil))
        } failure: { error in
            completion(.failure(error!))
        }
    }
    
}

extension DeviceService: TuyaSmartDeviceDelegate {
    func deviceInfoUpdate(_ device: TuyaSmartDevice) {
        guard let dispatch = DeviceService.shared.dispatch else { return  }
        
        dispatch(DeviceAction.updateDevice(device))
    }
    
    func device(_ device: TuyaSmartDevice, dpsUpdate dps: [AnyHashable : Any]) {
        guard let dispatch = DeviceService.shared.dispatch else { return  }
        
        dispatch(DeviceAction.updateDevice(device))
    }
}


enum DeviceAction: Action {
    
    case updateDevice(_ device: TuyaSmartDevice)
    case updateDevices(_ devices: [TuyaSmartDeviceModel])
    
    case operatorfailed(error: Error)
    case startDeleteDevice
    
    case startPublishDps
    case updateDps(_ dps: [AnyHashable : Any], dpId: String)
    
    
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
    
    static func initDevice(with devId: String) -> AppThunkAction {
        AppThunkAction { dispatch, getState in
            guard let device = TuyaSmartDevice.init(deviceId: devId) else { return }
            device.delegate = DeviceService.shared
            dispatch(DeviceAction.updateDevice(device))
        }
    }
    
    static func publishDps(with dps: [AnyHashable : Any], dpId: String) -> AppThunkAction {
        AppThunkAction { dispatch, getState in
            guard let device = getState()?.deviceState.device else { return }
            
            dispatch(DeviceAction.startPublishDps)
            
            DeviceService.shared.publishDps(with: device, dps: dps, dispatch: dispatch) { result in
                switch result {
                case .success(_):
                    dispatch(DeviceAction.updateDps(dps, dpId: dpId))
                    break
                case .failure(let error):
                    dispatch(DeviceAction.operatorfailed(error: error))
                    break
                }
            }
        }
    }
}
