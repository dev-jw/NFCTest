//
//  NFCTool.swift
//  TuyaSmartNFC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import Foundation
import CoreNFC
import TuyaSmartDeviceKit

typealias NFCFinishCompletion = (Result<NFCNDEFMessage?, Error>) ->Void

enum NFCError: LocalizedError {
    case unavailable
    case invalidated(message: String)
    case invalidPayloadSize
    
    var errorDescription: String? {
        switch self {
        case .unavailable:
            return "NFC Reader Not Available"
        case let .invalidated(message):
            return message
        case .invalidPayloadSize:
            return "NDEF payload size exceeds the tag limit"
        }
    }
}

class NFCTool: NSObject {
    enum NFCAction {
        case readTag
        case writeTag(dps: String)
        
        var alertMessage: String  {
            switch self {
            case .readTag:
                return "Place tag near iPhone to read."
            case .writeTag(let dps):
                return "Place tag near iPhone to write \(dps)"
            }
        }
    }
    
    private static let shared = NFCTool()
    
    private var action: NFCAction = .readTag
    private var completion: NFCFinishCompletion?
    
    private var readerSession: NFCTagReaderSession?
    
    static func performAction(_ action: NFCAction, completion: NFCFinishCompletion? = nil) {
        guard NFCNDEFReaderSession.readingAvailable else {
            completion?(.failure(NFCError.unavailable))
            print("NFC is not available on this device")
            return
        }
        
        shared.action = action
        shared.completion = completion
        
        shared.readerSession = NFCTagReaderSession(pollingOption: .iso14443, delegate: shared.self, queue: nil)
        shared.readerSession?.alertMessage = "Hold your iPhone near an NFC fish tag."
        shared.readerSession?.begin()
    }
}

// MARK: - NFCTagReaderSessionDelegate
extension NFCTool: NFCTagReaderSessionDelegate {
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        // If necessary, you may perform additional operations on session start.
        // At this point RF polling is enabled.
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        // If necessary, you may handle the error. Note the session is no longer valid.
        // You must create a new session to restart RF polling.
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        var tag: NFCTag? = nil
        
        for nfcTag in tags {
            // In this example you are searching for a MIFARE Ultralight tag (NFC Forum T2T tag platform).
            if case let .miFare(mifareTag) = nfcTag {
                if mifareTag.mifareFamily == .ultralight || mifareTag.mifareFamily == .unknown {
                    tag = nfcTag
                    break
                }
            }
        }
        
        if tag == nil {
            session.invalidate(errorMessage: "No valid tag found.")
            return
        }
        
        session.connect(to: tag!) { (error: Error?) in
            if error != nil {
                session.invalidate(errorMessage: "Connection error. Please try again.")
                return
            }

             self.readMiFareTag(from: tag!)
//            self.testWriteInitData(to: tag!)
        }
    }
}

// MARK: - Private
extension NFCTool {
    private func handleError(_ error: Error) {
        readerSession?.alertMessage = error.localizedDescription
        readerSession?.invalidate()
    }
    
    private func readMiFareTag(from tag: NFCTag) {
        guard case let .miFare(mifareTag) = tag else {
            return
        }
        
        DispatchQueue.global().async {
            
            self.write(to: mifareTag)

            
            //            let blockSize = 16
            //            let useCounterOffset = 2
            //            let lengthOffset = 3
            //            let headerLength = 4
            //            let maxCodeLength = 16
            
            // Send password
//            let readBlock4: [UInt8] = [0x1B, 0x66, 0x66, 0x66, 0x66]
//            self.sendReadTagCommand(Data(readBlock4), to: mifareTag) { (responseBlock4: Data) in
//                print("response: \(responseBlock4)")
//
//
////                self.testWriteInitData(to: tag)
//
//                // require Real Word
//                let magicSignature: [UInt8] = [0x30, 0xD0]
//                self.sendReadTagCommand(Data(magicSignature), to: mifareTag) { (realData: Data) in
//                    print("realData: \(realData)")
//
//                    // writer NDEF message
//                    self.write(to: mifareTag)
//                }
//            }
        }
    }
    
    
    func testWriteInitData(to tag: NFCTag) {
        guard case let .miFare(mifareTag) = tag else {
            return
        }
        
        DispatchQueue.global().async {
            
            // block3 save size
            let writeBlockCommand: UInt8 = 0x30
            
            let dataOffset: UInt8 = 3 & 0x0ff
//            let data: UInt8 = 0x11
                        
            let writeCommand = Data([writeBlockCommand, dataOffset])

            
            self.sendReadTagCommand(writeCommand, to: mifareTag) { (responseBlock4: Data) in
                print("response: \(responseBlock4)")
        
            }
        }
    }
    
    
    // MARK: - Private helper functions
    private func sendReadTagCommand(_ data: Data, to tag: NFCMiFareTag, _ completionHandler: @escaping (Data) -> Void) {
        if #available(iOS 14, *) {
            tag.sendMiFareCommand(commandPacket: data) { [self] (result: Result<Data, Error>) in
                switch result {
                case .success(let response):
                    completionHandler(response)
                case .failure(let error):
                    readerSession?.invalidate(errorMessage: "Read tag error: password is invoke.")
                }
            }
        } else {
            tag.sendMiFareCommand(commandPacket: data) { (response: Data, optionalError: Error?) in
                guard let error = optionalError else {
                    completionHandler(response)
                    return
                }
                
                self.readerSession?.invalidate(errorMessage: "Read tag error: \(error.localizedDescription). Please try again.")
            }
        }
    }
    
    private func write(to tag: NFCMiFareTag) {
        tag.queryNDEFStatus { [self] (status, _, error) in
            if let error = error {
                self.handleError(error)
                return
            }
            
            switch (status, self.action) {
            case (.notSupported, _):
                readerSession?.alertMessage = "Unsupported tag."
                readerSession?.invalidate()
            case (.readOnly, _):
                readerSession?.alertMessage = "Unable to write to tag."
                readerSession?.invalidate()
            case (.readWrite, .writeTag(let dps)):
                self.writeData(to: tag, dps: dps)
            case (.readWrite, .readTag):
                self.readTag(from: tag)
            default:
                return
            }
        }
    }
    
    private func writeData(to tag: NFCMiFareTag, dps: String) {
        
        
        let ios = NFCNDEFPayload.wellKnownTypeURIPayload(string: String("https://tuyasmart.app.tuya.com/"))
//        let ios = NFCNDEFPayload.wellKnownTypeURIPayload(string: String("https://smartlife.app.tuya.com/"))
        
        let android = NFCNDEFPayload(format: .nfcExternal,
                                     type: String("android.com:pkg").data(using: .utf8)!,
                                     identifier: Data(),
                                     payload: String("com.tencent.mm").data(using: .utf8)!)
        
        let payload = NFCNDEFPayload(format: .nfcExternal,
                                     type: String("tuya.smart:tuyanfc").data(using: .utf8)!,
                                     identifier: String("com.tuya.smart").data(using: .utf8)!,
                                     payload: dps.data(using: .utf8)!)
        
        //        let urlPayload = NFCNDEFPayload(format: .nfcWellKnown,
        //                                     type: String("U").data(using: .utf8)!,
        //                                     identifier: String("com.tuya.smart").data(using: .utf8)!,
        //                                     payload: String("\u{04}wut.im").data(using: .utf8)!)
        
        
        let NDEFMessage = NFCNDEFMessage(records: [payload, android, ios!])
        
        tag.writeNDEF(NDEFMessage) { [self] error in
            if let error = error {
                self.handleError(error)
                return
            }
            readerSession?.alertMessage = "Write Successed!"
            readerSession?.invalidate()
        }
    }
    
    private func readTag(from tag: NFCMiFareTag, alertMessage: String = "Tag Read & DP Publish") {
        tag.readNDEF { [self] (message, error) in
            if let error = error {
                self.handleError(error)
                return
            }
            
            if let message = message,
               let record = message.records.first {
                
                let type = "tuya.smart:tuyanfc"
                if let p = String(data: record.type, encoding: .utf8), (p.compare(type).rawValue == 0)  {
                    
                    let content = String(data: record.payload, encoding: .utf8)
                    
                    let data = content!.data(using: String.Encoding.utf8)
                    let dict = try? JSONSerialization.jsonObject(with: data!,
                                                                 options: .mutableContainers)
                    
                    let dicts = dict as! Dictionary<String, Any>
                    
                    let dpId = dicts["dpId"] as! String
                    let devId = dicts["devId"] as! String
 
                    guard let device = TuyaSmartDevice.init(deviceId: devId), let _ = device.deviceModel.dps else {
                        return
                    }
                                        
                    let value: Bool = device.deviceModel.dps[dpId] as! Bool
                    
                    let dps = [dpId: !value]
                    
                    device.publishDps(dps as [AnyHashable : Any], success: {
                        print("dps publish success")
                        
                        readerSession?.alertMessage = alertMessage
                        readerSession?.invalidate()
                        
                        self.completion?(.success(message))
                        
                    }, failure: { (error) in
                        print("dps publish failure \(String(describing: error?.localizedDescription))")
                        
                        readerSession?.alertMessage = "dps publish failure :" + error!.localizedDescription
                        readerSession?.invalidate()
                    })
                }
                
            } else {
                readerSession?.alertMessage = "Could not decode tag data."
                readerSession?.invalidate()
            }
        }
    }
    
}
