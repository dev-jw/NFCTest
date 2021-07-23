//
//  SceneDelegate.swift
//  TuyaSmartNFC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import SwiftUI
import CoreNFC

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    private lazy var main: AppMain = .init()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        let rootView = ContentView().environmentObject(main.store)
        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: rootView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb else {
            fatalError("error")
        }
        
        // Confirm that the NSUserActivity object contains a valid NDEF message.
        let ndefMessage = userActivity.ndefMessagePayload
        guard ndefMessage.records.count > 0,
              ndefMessage.records[0].typeNameFormat != .empty else {
            fatalError("error")
        }
        
        TYNFCModuleService.sharedInstance.readData(from: ndefMessage) { [self] res in
                        
            let alert = UIAlertController(title: "tips", message: res.description, preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))

            guard let rootVc = window?.rootViewController else {
                fatalError("error")
            }

            rootVc.present(alert, animated: true, completion: nil)
            
        } failure: { [self] error in
            
            let alert = UIAlertController(title: "tips", message: error?.localizedDescription ?? "error", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))

            guard let rootVc = window?.rootViewController else {
                fatalError("error")
            }

            rootVc.present(alert, animated: true, completion: nil)
        }
    }
}

