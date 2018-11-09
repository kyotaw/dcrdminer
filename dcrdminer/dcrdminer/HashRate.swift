//
//  HashRate.swift
//  dcrdminer
//
//  Created by Kyota Watanabe on 2018/11/04.
//  Copyright © 2018 watanabe kyota. All rights reserved.
//

import Foundation

protocol  HashRateDelegate {
    func receiveHashRate(hashRateMhPerSec: Float)
}

class HashRate {
    init() {
        self.count = 0
        self.queue = DispatchQueue(label: "HashRate")
    }
    
    func start() {
        self.queue.async {
            while true {
                let start = Date().timeIntervalSince1970
                self.monitor()
                let end = Date().timeIntervalSince1970
                var interval = 1.0 - (end - start)
                if interval < 0 {
                    interval = 0.0
                }
                Thread.sleep(forTimeInterval: interval)
            }
        }
    }
    
    func countUp() {
        self.count += 1
    }
    
    func monitor() {
        let rate = self.count / 1000.0
        self.delegate?.receiveHashRate(hashRateMhPerSec: rate)
        self.count = 0
    }
    
    var count: Float
    let queue: DispatchQueue
    var delegate: HashRateDelegate?
}
