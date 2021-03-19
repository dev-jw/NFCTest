//
//  ActivatorAction.swift
//  TuyaSmartNFC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import Foundation
import ReSwift
import ReSwiftThunk
import TuyaSmartActivatorKit

enum ActivatorAction: Action {
    case matching
    case updateToken(token: String)
    case updateResult(result: String)
    case operatorfailed(error: Error)
    case stopConfig
    
    static func fetchToken() -> AppThunkAction {
        AppThunkAction { dispatch, getState in
            guard let homeId = getState()?.homeState.currentHome?.homeModel.homeId else {
                return
            }
            
            dispatch(ActivatorAction.matching)
            ActivatorService.getToken(with: homeId, dispatch: dispatch) { res in
                switch res {
                case .success(let token):
                    dispatch(ActivatorAction.updateToken(token: token as! String))
                    break
                case .failure(let error):
                    dispatch(ActivatorAction.operatorfailed(error: error))
                    break
                }
            }
        }
    }
    
    
    static func startConfig(with mode: TYActivatorMode, ssid: String?, password: String?) -> AppThunkAction {
        AppThunkAction { dispatch, getState in
            guard let token = getState()?.activatorState.token else {
                return
            }
            
            dispatch(ActivatorAction.matching)
            ActivatorService.shared.activator!.startConfigWiFi(mode, ssid: ssid, password: password, token: token, timeout: 120)
        }
    }
    
    static func startConfig(isSub: Bool? = false) -> AppThunkAction {
        AppThunkAction { dispatch, getState in
            guard let token = getState()?.activatorState.token else {
                return
            }
            
            dispatch(ActivatorAction.matching)
            
            if isSub! {
                
                guard let devices = getState()?.deviceState.devices else {
                    return
                }
                
                var gatewayDevice: TuyaSmartDeviceModel?
                for deviceModel in devices {
                    if (deviceModel.deviceType == TuyaSmartDeviceModelTypeZigbeeGateway && deviceModel.isOnline) {
                        gatewayDevice = deviceModel
                        break
                    }
                }
                
                guard let gateway = gatewayDevice else {
                    return
                }
                
                
                ActivatorService.shared.activator!.activeSubDevice(withGwId: gateway.devId, timeout: 120)
                
            }else {
                ActivatorService.shared.activator!.startConfigWiFi(withToken: token, timeout: 120)
            }
        }
    }
    
    static func stopConfig(isSub: Bool? = false) -> AppThunkAction  {
        AppThunkAction { dispatch, getState in
            
            if isSub! {
                
                guard let devices = getState()?.deviceState.devices else {
                    return
                }
                
                var gatewayDevice: TuyaSmartDeviceModel?
                for deviceModel in devices {
                    if (deviceModel.deviceType == TuyaSmartDeviceModelTypeZigbeeGateway && deviceModel.isOnline) {
                        gatewayDevice = deviceModel
                        break
                    }
                }
                
                guard let gateway = gatewayDevice else {
                    return
                }
                
                ActivatorService.shared.activator!.delegate = nil
                ActivatorService.shared.activator!.stopActiveSubDevice(withGwId: gateway.devId)
                dispatch(ActivatorAction.stopConfig)
            }else {
                
                ActivatorService.shared.activator!.delegate = nil
                ActivatorService.shared.activator!.stopConfigWiFi()
                dispatch(ActivatorAction.stopConfig)
            }
            
        }
    }
}

class ActivatorService: NSObject {
    
    let activator = TuyaSmartActivator.sharedInstance()
    
    static let shared = ActivatorService()
    
    private var dispatch: DispatchFunction?
    
    static func getToken(with homeId: Int64, dispatch: @escaping DispatchFunction, completion: @escaping ServiceCompletion = { _ in }) {
        
        shared.dispatch = dispatch
        
        shared.activator!.delegate = shared
        
        shared.activator!.getTokenWithHomeId(homeId, success: { (result) in
            completion(.success(result!))
        }, failure: { error in
            completion(.failure(error!))
        })
    }
}

extension ActivatorService: TuyaSmartActivatorDelegate {
    func activator(_ activator: TuyaSmartActivator!, didReceiveDevice deviceModel: TuyaSmartDeviceModel!, error: Error!) {
        
        guard let dispatch = ActivatorService.shared.dispatch else { return  }
        
        guard let error = error else {
            
            guard let deviceModel = deviceModel else {
                dispatch(ActivatorAction.matching)
                return
            }
            dispatch(ActivatorAction.updateResult(result: "Success-You've added device \(String(describing: deviceModel.name))! successfully!"))
            dispatch(DeviceAction.fetchDevices())
            return
        }
        
        dispatch(ActivatorAction.updateResult(result: "Activator: Error - \(error.localizedDescription)"))
    }
}
