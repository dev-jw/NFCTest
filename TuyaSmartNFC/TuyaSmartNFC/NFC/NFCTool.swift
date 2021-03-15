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
        case readTag(device: TuyaSmartDevice?)
        case writeTag(dps: String)
    
        var alertMessage: String  {
            switch self {
            case .readTag(let device):
                return "Place tag near iPhone to read \(device!)."
            case .writeTag(let dps):
                return "Place tag near iPhone to write \(dps)"
            }
        }
    }
    
    private static let shared = NFCTool()
    
    private var action: NFCAction = .readTag(device: nil)
    
    private var session: NFCNDEFReaderSession?
    private var completion: NFCFinishCompletion?
    
    static func performAction(_ action: NFCAction, completion: NFCFinishCompletion? = nil) {
        guard NFCNDEFReaderSession.readingAvailable else {
            completion?(.failure(NFCError.unavailable))
            print("NFC is not available on this device")
            return
        }
        
        shared.action = action
        shared.completion = completion

        shared.session = NFCNDEFReaderSession(delegate: shared.self, queue: nil, invalidateAfterFirstRead: false)

        shared.session?.alertMessage = action.alertMessage
        shared.session?.begin()

        
    }
}

extension NFCTool: NFCNDEFReaderSessionDelegate {
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        if let error = error as? NFCReaderError,
           error.code != .readerSessionInvalidationErrorFirstNDEFTagRead &&
            error.code != .readerSessionInvalidationErrorUserCanceled {
            completion?(.failure(NFCError.invalidated(message: error.localizedDescription)))
        }
        
        self.session = nil
        completion = nil
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        guard let tag = tags.first, tags.count == 1 else {
            session.alertMessage = "There are too many tags present. Remove all and then try again."
            DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(500)) {
                session.restartPolling()
            }
            return
        }
        
        session.connect(to: tag) { error in
            if let error = error {
                self.handleError(error)
                return
            }
            
            tag.queryNDEFStatus { (status, _, error) in
                if let error = error {
                    self.handleError(error)
                    return
                }
                
                switch (status, self.action) {
                case (.notSupported, _):
                    session.alertMessage = "Unsupported tag."
                    session.invalidate()
                case (.readOnly, _):
                    session.alertMessage = "Unable to write to tag."
                    session.invalidate()
                case (.readWrite, .writeTag(let dps)):
                    self.writeTag(tag: tag, dps: dps)
                case (.readWrite, .readTag(let device)):
                    self.readTag(tag: tag, device: device!)
                default:
                    return
                }
                
            }
        }
    }
}

extension NFCTool {
    private func handleError(_ error: Error) {
        session?.alertMessage = error.localizedDescription
        session?.invalidate()
    }

    
    private func writeTag(tag: NFCNDEFTag, dps: String) {
        let payload = NFCNDEFPayload(format: .nfcWellKnown,
                                     type: String("P").data(using: .utf8)!,
                                     identifier: String("com.tuya.smart").data(using: .utf8)!,
                                     payload: dps.data(using: .utf8)!)

        let urlPayload = NFCNDEFPayload(format: .nfcWellKnown,
                                     type: String("U").data(using: .utf8)!,
                                     identifier: String("com.tuya.smart").data(using: .utf8)!,
                                     payload: String("\u{04}wut.im").data(using: .utf8)!)

        
        let NDEFMessage = NFCNDEFMessage(records: [payload, urlPayload])
        
        tag .writeNDEF(NDEFMessage) { error in
            if let error = error {
                self.handleError(error)
                return
            }
            self.session?.alertMessage = "Write Successed!"
            self.session?.invalidate()
        }
    }
    
    private func readTag(
        tag: NFCNDEFTag,
        device: TuyaSmartDevice,
        alertMessage: String = "Tag Read & DP Publish"
    ) {
        tag.readNDEF { (message, error) in
            if let error = error {
                self.handleError(error)
                return
            }
            
            // 1
            if let message = message,
               let record = message.records.first {
                // 2
                guard let dp = device.deviceModel.dps else {
                    return
                }
                
                if let p = String(data: record.type, encoding: .utf8), (p.compare("P").rawValue == 0)  {

                    let content = String(data: record.payload, encoding: .utf8)
                    
                    let data = content!.data(using: String.Encoding.utf8)
                    let dict = try? JSONSerialization.jsonObject(with: data!,
                                    options: .mutableContainers)
                    
                    let dicts = dict as! Dictionary<String, Any>
                        
                    let dpPoint = dicts["dp"] as! String
                    
                    let value = (dp[dpPoint] == nil)
                    
                    let dps = [dpPoint : value]
                    
                    device.publishDps(dps as [AnyHashable : Any], success: {
                        print("dps publish success")

                        self.session?.alertMessage = alertMessage
                        self.session?.invalidate()

                        self.completion?(.success(message))
                        
                    }, failure: { (error) in
                        print("dps publish failure \(String(describing: error?.localizedDescription))")
                    
                        self.session?.alertMessage = "dps publish failure :" + error!.localizedDescription
                        self.session?.invalidate()                        
                    })
                }
                
            } else {
                self.session?.alertMessage = "Could not decode tag data."
                self.session?.invalidate()
            }
        }
    }
}
