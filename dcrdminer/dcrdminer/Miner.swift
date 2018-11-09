//
//  Miner.swift
//  dcrdminer
//
//  Created by Kyota Watanabe on 2018/11/03.
//  Copyright © 2018 watanabe kyota. All rights reserved.
//

import Foundation

protocol MinerDelegate {
    func foundNonce(nonce: UInt32, extraNonce: UInt32, hash: String, job: PoolJob)
    func receiveHashRate(hashRate: Float)
}

class Miner : HashRateDelegate {
    init(id: UInt8) {
        self.id = id
        self.nonceCounter = NonceCounter(value: 0)
        self.extraNonceCounter = NonceCounter(value: 0)
        self.isMining = false
        self.queue = DispatchQueue(label: "Miner")
        self.hashRate = HashRate()
        self.hashRate.delegate = self
        self.hashRate.start()
    }
    
    func mineHash(job: PoolJob) {
        self.isMining = true
        self.currentJob = job
        self.workData = job.work.blockHeader.copy()
        self.extraNonceCounter.rollOver()
        
        self.workData.setBytes(pos: BlockHeader.extraNonceMinerIdPos, values: [self.id])
        self.workData.setBytes(pos: BlockHeader.extraNonceCounterPos, values: self.extraNonceCounter.bytes)
        
        let blake256 = Blake256(round: 14)
        
        self.queue.async {
            while self.isMining {
                self.workData.setBytes(pos: BlockHeader.noncePos, values: self.nonceCounter.bytes)
                let hash = blake256.hash(input: self.workData.bytes)
                //print("Hash: " + hash)
                self.hashRate.countUp()
                if self.evaluateHash(hash: hash) {
                    print("Found: " + hash)
                    self.delegate?.foundNonce(nonce: self.nonceCounter.nonce, extraNonce: self.extraNonceCounter.nonce, hash: hash, job: self.currentJob)
                } else {
                    self.nonceCounter.rollOver()
                }
            }
        }
    }
    
    fileprivate func evaluateHash(hash: String) -> Bool {
        let targetDiff = self.currentJob.work.targetDifficulty
        let hashTarget = String(hash.prefix(targetDiff))
        for s in hashTarget {
            if s != "0" {
                return false
            }
        }
        return true
    }
    
    // HashRateDelegate
    func receiveHashRate(hashRateMhPerSec: Float) {
        self.delegate?.receiveHashRate(hashRate: hashRateMhPerSec)
    }

    let id: UInt8
    var delegate: MinerDelegate?
    var currentJob: PoolJob!
    var workData: BlockHeader!
    var nonceCounter: NonceCounter
    var extraNonceCounter: NonceCounter
    var isMining: Bool
    var hashRate: HashRate
    var queue: DispatchQueue
}
