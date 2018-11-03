//
//  PoolJob.swift
//  dcrdminer
//
//  Created by Kyota Watanabe on 2018/10/28.
//  Copyright © 2018 watanabe kyota. All rights reserved.
//

import Foundation


class PoolJob {
    init(subscribeResult: SubscribeResult, notifyMethod: NotifyMethod, difficulty: SetDifficultyMethod) {
        self.jobId = notifyMethod.jobId
        self.nbits = notifyMethod.nbits
        self.ntime = notifyMethod.ntime
        self.isClean = notifyMethod.isCleanJob
        let blockHeader = BlockHeader(notifyMethod: notifyMethod, subscribeResult: subscribeResult)
        self.work = Work(blockHeader: blockHeader, targetDifficulty: difficulty.difficulty)
    }
    
    let jobId: String
    let nbits: String
    let ntime: String
    let isClean: Bool
    var work: Work
}
