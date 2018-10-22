//
//  Stream.swift
//  dcrdminer
//
//  Created by 渡部郷太 on 2018/10/21.
//  Copyright © 2018 watanabe kyota. All rights reserved.
///Users/kyota/work/ZaifSwift/ZaifSwift/Resource.swift

import Foundation
import SwiftyJSON

protocol StratumDelegate {
    func receiveMessage(message: SubscriveResult)
    func receiveMessage(message: NotifyMethod)
    func receiveMessage(message: SetDifficultyMethod)
}

public struct SubscriveResult : Decodable {
    init?(json: JSON) {
        guard let id = json["id"].int else {
            return nil
        }
        self.id = id
        guard let resultArray = json["result"].array else {
            return nil
        }
        
        self.subscribeId = ""
        let tuples = resultArray[0].arrayValue
        for tuple in tuples {
            if tuple[0].stringValue == "mining.notify" {
                self.subscribeId = tuple[1].stringValue
            }
        }
        if self.subscribeId == "" {
            return nil
        }
        
        guard let extranonce1 = resultArray[1].string else {
            return nil
        }
        self.extranonce1 = extranonce1
        
        guard let extranonce2Size = resultArray[2].int else {
            return nil
        }
        self.extranonce2Size = extranonce2Size
    }
    
    var id: Int
    var subscribeId: String
    var extranonce1: String
    var extranonce2Size: Int
}

public struct NotifyMethod {
    init?(json: JSON) {
        if let id = json["id"].int {
            self.id = id
        }
        
        guard let params = json["params"].array else {
            return nil
        }
        guard let jobId = params[0].string else {
            return nil
        }
        self.jobId = jobId
        
        guard let prevHash = params[1].string else {
            return nil
        }
        self.prevBlockHash = prevHash
        
        guard let genTx1 = params[2].string else {
            return nil
        }
        self.genTx1 = genTx1
        
        guard let genTx2 = params[3].string else {
            return nil
        }
        self.genTx2 = genTx2
        
        guard let merkleBranches = params[4].array else {
            return nil
        }
        self.merkleBranches = merkleBranches.map() { j in j.stringValue }
        
        guard let blockVersion = params[5].string else {
            return nil
        }
        self.blockVersion = blockVersion
        
        guard let nBits = params[6].string else {
            return nil
        }
        self.nBits = nBits
        
        guard let nTime = params[7].string else {
            return nil
        }
        self.nTime = nTime
        
        guard let isCleanJob = params[8].bool else {
            return nil
        }
        self.isCleanJob = isCleanJob
    }
    
    var id: Int?
    var jobId: String
    var prevBlockHash: String
    var genTx1: String
    var genTx2: String
    var merkleBranches: [String]
    var blockVersion: String
    var nBits: String
    var nTime: String
    var isCleanJob: Bool
}

public struct SetDifficultyMethod {
    init?(json: JSON) {
        if let id = json["id"].int {
            self.id = id
        }
        
        guard let params = json["params"].array else {
            return nil
        }
        guard let difficulty = params[0].float else {
            return nil
        }
        self.difficulty = difficulty
    }
    
    var id: Int?
    var difficulty: Float
}

open class Stratum : NSObject, StreamDelegate {
    
    init(host: String, port: Int, delegate: StratumDelegate) {
        self.host = host
        self.port = port
        self.delegate = delegate
        super.init()
        Stream.getStreamsToHost(withName: host, port: port, inputStream: &self.inStream, outputStream: &self.outStream)
        self.outStream?.delegate = self
        self.inStream?.delegate = self
        self.outStream?.schedule(in: .main, forMode: RunLoop.Mode.common)
        self.outStream?.open()
        self.inStream?.schedule(in: .main, forMode: RunLoop.Mode.common)
        self.inStream?.open()
    }
    
    open func subscribe() {
        let data: [String:Any] = [
            "id": 1,
            "method": "mining.subscribe",
            "params": ["dcrdminer/"]
        ]
        let jsonData = try! JSONSerialization.data(withJSONObject: data, options: [])
        let jsonStr = String(bytes: jsonData, encoding: .utf8)!
        self.sendData(dataString: jsonStr + "\n")
    }
    
    private func sendData(dataString: String) {
        let dataUint8 = [UInt8](dataString.utf8)
        let data = UnsafePointer<UInt8>(dataUint8)
        self.outStream?.write(data, maxLength: dataUint8.count)
    }
    
    public func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case Stream.Event.hasBytesAvailable:
            let messages = self.readInputData(stream: aStream as! InputStream)
            for message in messages {
                self.dispachMessage(message: message)
            }
        case Stream.Event.endEncountered:
            print("<End Encountered>")
        case Stream.Event.errorOccurred:
            print("<Error occurred>")
        case Stream.Event.openCompleted:
            self.status = .connected
            print("<Error occurred>")
        case Stream.Event.hasSpaceAvailable:
            if self.status == .connected {
                self.subscribe()
                self.status = .subscribeRequested
            }
        default:
            print("<Some other event>")
        }
    }
    
    private func readInputData(stream: InputStream) -> [String] {
        var data = ""
        while stream.hasBytesAvailable {
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 4096)
            let numberOfBytesRead = stream.read(buffer, maxLength: 4096)
            if numberOfBytesRead < 0 {
                if stream.streamError != nil {
                    break
                }
            }
            data += String(bytesNoCopy: buffer, length: numberOfBytesRead, encoding: .utf8, freeWhenDone: true)!
        }
        var messages = data.components(separatedBy: "\n")
        let _ = messages.popLast()
        return messages
    }
    
    private func dispachMessage(message: String) {
        let json = JSON(parseJSON: message)
        if json["result"].array != nil{
            guard let subscribeResult = SubscriveResult(json: json) else {
                print("Failed to parse SubscribeResult")
                return
            }
            self.delegate.receiveMessage(message: subscribeResult)
        } else if let method = json["method"].string {
            switch method {
            case "mining.notify":
                guard let notifyMethod = NotifyMethod(json: json) else {
                    print("Failed to parse NotifyMethod")
                    return
                }
                self.delegate.receiveMessage(message: notifyMethod)
            case "mining.set_difficulty":
                guard let setDifficultyMethod = SetDifficultyMethod(json: json) else {
                    print("Failed to parse SetDifficultyMethod")
                    return
                }
                self.delegate.receiveMessage(message: setDifficultyMethod)
            default:
                print("Unknown message: " + method)
            }
            
        }
    }
    
    private let host: String
    private let port : Int
    private let delegate: StratumDelegate
    private var inStream: InputStream? = nil
    private var outStream: OutputStream? = nil
    private var status: StratumState = .disConnected
}

private enum StratumState {
    case disConnected
    case connected
    case subscribeRequested
    case subscribing
}
