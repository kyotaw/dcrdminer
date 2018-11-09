//
//  Currency.swift
//  zai
//
//  Created by Kyota Watanabe on 8/19/16.
//  Copyright © 2016 Kyota Watanabe. All rights reserved.
//

import Foundation

fileprivate func getNow() -> String {
    let now = NSDate()
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
    return formatter.string(from: now as Date)
}

enum UpdateInterval : Int {
    case realTime
    case oneSecond
    case twoSeconds
    case fiveSeconds
    case tenSeconds
    case thirtySeconds
    case oneMinute
    
    var string: String {
        switch self {
        case .realTime: return "リアルタイム"
        case .oneSecond: return "1秒"
        case .twoSeconds: return "2秒"
        case .fiveSeconds: return "5秒"
        case .tenSeconds: return "10秒"
        case .thirtySeconds: return "30秒"
        case .oneMinute: return "60秒"
        }
    }
    
    var int: Int {
        switch self {
        case .realTime: return 0
        case .oneSecond: return 1
        case .twoSeconds: return 2
        case .fiveSeconds: return 5
        case .tenSeconds: return 10
        case .thirtySeconds: return 30
        case .oneMinute: return 60
        }
    }
    
    var double: Double {
        switch self {
        case .realTime: return 0.5
        case .oneSecond: return 1.0
        case .twoSeconds: return 2.0
        case .fiveSeconds: return 5.0
        case .tenSeconds: return 10.0
        case .thirtySeconds: return 30.0
        case .oneMinute: return 60.0
        }
    }
    
    static var count: Int = {
        var i = 0
        while let _ = UpdateInterval(rawValue: i) {
            i += 1
        }
        return i
    }()
}

@objc protocol MonitorableDelegate {
    @objc optional func getDelegateName() -> String
}

internal class Monitorable {
    
    init(target: String, addOperation: Bool=true) {
        self.target = target
        self.queue = DispatchQueue.global()
        if addOperation {
            self.addMonitorOperation()
        }
    }
    
    @objc func addMonitorOperation() {
        self.queue.async {
            var log = "\(getNow()) do monitoring \(self.target) delegate: "
            if let _ = self.delegate?.getDelegateName {
                log += (self.delegate?.getDelegateName!())!
            }
            print(log)
            self.monitor()
        }
    }
    
    func monitor() {
        return
    }
    
    var monitoringInterval: UpdateInterval {
        get {
            return self._monitoringInterval
        }
        set {
            self._monitoringInterval = newValue
            if self.timer != nil {
                self.timer?.invalidate()
                self.timer = nil
                var log = "\(getNow()) start monitoring \(self.target) interval: \(self._monitoringInterval.string) delegate: "
                if let _ = self.delegate?.getDelegateName {
                    log += (self.delegate?.getDelegateName!())!
                }
                print(log)
                self.timer = Timer.scheduledTimer(
                    timeInterval: self._monitoringInterval.double,
                    target: self,
                    selector: #selector(Monitorable.addMonitorOperation),
                    userInfo: nil,
                    repeats: true)
            }
        }
    }
    
    var delegate: MonitorableDelegate? = nil {
        willSet {
            if newValue == nil {
                var log = "\(getNow()) end monitoring \(self.target) delegate: "
                if let _ = self.delegate?.getDelegateName {
                    log += (self.delegate?.getDelegateName!())!
                }
                print(log)
                self.timer?.invalidate()
                self.timer = nil
            } else {
                if self.timer == nil {
                    var log = "\(getNow()) start monitoring \(self.target) interval: \(self._monitoringInterval.string) delegate: "
                    if let _ = self.delegate?.getDelegateName {
                        log += (self.delegate?.getDelegateName!())!
                    }
                    print(log)
                    self.timer = Timer.scheduledTimer(
                        timeInterval: self._monitoringInterval.double,
                        target: self,
                        selector: #selector(Monitorable.addMonitorOperation),
                        userInfo: nil,
                        repeats: true)
                }
            }
        }
        didSet {
            self.monitor()
        }
    }
    
    
    let target: String
    let queue: DispatchQueue!
    var timer: Timer?
    var _monitoringInterval = UpdateInterval.fiveSeconds
    
}

