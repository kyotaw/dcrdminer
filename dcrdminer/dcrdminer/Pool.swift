//
//  Pool.swift
//  dcrdminer
//
//  Created by Kyota Watanabe on 2018/11/03.
//  Copyright © 2018 watanabe kyota. All rights reserved.
//

import Foundation

protocol PoolDelegate {
    func receiveJob(job: PoolJob)
}

class Pool : StratumDelegate {
    init(host: String, port: Int, workerName: String, password: String) {
        self.stratum = Stratum(host: host, port: port)
        self.jobCount = 0
    }
    
    func subscribe(subscriber: PoolDelegate) {
        self.delegate = subscriber
        self.stratum.subscribe(subscriber: self)
    }
    
    func receiveMessage(message: SubscribeResult) {
        self.subscribeRresult = message
        self.prepareJob()
    }
    
    func receiveMessage(message: NotifyMethod) {
        self.notifyMethod = message
        self.prepareJob()
    }
    
    func receiveMessage(message: SetDifficultyMethod) {
        self.setDifficultyMethod = message
        self.prepareJob()
    }
    
    private func prepareJob() {
        guard let sr = self.subscribeRresult else {
            return
        }
        guard let sdm = self.setDifficultyMethod else {
            return
        }
        guard let nm = self.notifyMethod else {
            return
        }
        let job = PoolJob(subscribeResult: sr, notifyMethod: nm, difficulty: sdm)
        self.jobCount += 1
        
        var randomBytes = [UInt8]()
        randomBytes.append(UInt8.random(in: 0 ... 255))
        randomBytes.append(UInt8.random(in: 0 ... 255))
        randomBytes.append(UInt8.random(in: 0 ... 255))
        job.work.blockHeader.setBytes(pos: BlockHeader.extraNonceRandomPos, values: randomBytes)
        
        self.delegate?.receiveJob(job: job)
    }
    
    let stratum: Stratum
    var subscribeRresult: SubscribeResult?
    var notifyMethod: NotifyMethod?
    var setDifficultyMethod: SetDifficultyMethod?
    var jobCount: Int32
    var delegate: PoolDelegate?
}
