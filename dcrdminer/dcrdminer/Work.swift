//
//  Work.swift
//  dcrdminer
//
//  Created by Kyota Watanabe on 2018/11/03.
//  Copyright © 2018 watanabe kyota. All rights reserved.
//

import Foundation

class Work {
    init(blockHeader: BlockHeader, targetDifficulty: Int64) {
        self.blockHeader = blockHeader
        self.targetDifficulty = targetDifficulty
        self.timestamp = Int64(NSDate().timeIntervalSince1970 * 1000)
    }
    
    var blockHeader: BlockHeader
    let targetDifficulty: Int64
    let timestamp: Int64
}
