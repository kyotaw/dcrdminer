//
//  Miner.swift
//  dcrdminer
//
//  Created by Kyota Watanabe on 2018/11/03.
//  Copyright © 2018 watanabe kyota. All rights reserved.
//

import Foundation

protocol MinerDelegate {

}

class Miner {
    init(id: UInt8) {
        self.id = id
        self.nonceCounter = NonceCounter(value: 0)
        self.extraNonceCounter = NonceCounter(value: 0)
    }
    
    func mineHash(job: PoolJob) {
        self.currentJob = job
        self.workData = job.work.blockHeader.copy()
        self.extraNonceCounter.rollOver()
        
        self.workData.setBytes(pos: BlockHeader.extraNonceMinerIdPos, values: [self.id])
        self.workData.setBytes(pos: BlockHeader.extraNonceCounterPos, values: self.extraNonceCounter.bytes)
    
    }

    let id: UInt8
    var delegate: MinerDelegate?
    var currentJob: PoolJob!
    var workData: BlockHeader!
    var nonceCounter: NonceCounter
    var extraNonceCounter: NonceCounter
}
