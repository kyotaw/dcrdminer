//
//  BlockHeader.swift
//  dcrdminer
//
//  Created by Kyota Watanabe on 2018/11/02.
//  Copyright © 2018 watanabe kyota. All rights reserved.
//

import Foundation

class BlockHeader {
    init(notifyMethod: NotifyMethod, subscribeResult: SubscribeResult) {
        let padSize = BlockHeader.extraDataBytes - (Hex(hexStr: subscribeResult.extraNonce1).bytes.count + subscribeResult.extraNonce2Length)
        let extraData = subscribeResult.extraNonce1 + Hex(size: subscribeResult.extraNonce2Length + padSize).str
        let header = notifyMethod.blockVersion + notifyMethod.prevBlockHash + notifyMethod.coinb1 + extraData + notifyMethod.coinb2
        self.bytes = Hex(hexStr: header).bytes
    }
    
    init(bytes: [UInt8]) {
        self.bytes = bytes
    }
    
    func copy() -> BlockHeader {
        return BlockHeader(bytes: self.bytes)
    }
    
    func setBytes(pos: Int, values: [UInt8]) {
        for (i, val) in values.enumerated() {
            self.bytes[pos + i] = val
        }
    }
    
    var bytes: [UInt8]
    
    // Block header layout
    static let blockHeaderBytes = 180
    static let versionBytes = 4
    static let versionPos = 0
    static let prevBlockHashBytes = 32
    static let prevBlockHashPos = 4
    static let merkleRootBytes = 32
    static let merkleRootPos = 36
    static let stakeRootBytes = 32
    static let stakeRootPos = 68
    static let voteBitsBytes = 2
    static let voteBitsPos = 100
    static let finalStateBytes = 6
    static let finalStatePos = 102
    static let votersBytes = 2
    static let votersPos = 108
    static let freshStakeBytes = 1
    static let freshStakePos = 110
    static let revocationsBytes = 1
    static let revocationsPos = 111
    static let poolSizeBytes = 4
    static let poolSizePos = 112
    static let bitsBytes = 4
    static let bitsPos = 116
    static let sBitsBytes = 8
    static let sBitsPos = 120
    static let heightBytes = 4
    static let heightPos = 128
    static let sizeBytes = 4
    static let sizePos = 132
    static let timestampBytes = 4
    static let timestampPos = 136
    static let nonceBytes = 4
    static let noncePos = 140
    static let extraDataBytes = 32
    static let extraDataPos = 144
    static let stakeVersionBytes = 4
    static let stakeVersionPos = 176
    
    // Extra nonce layout
    static let extraNonceCounterBytes = 4
    static let extraNonceCounterPos = BlockHeader.extraDataPos
    static let extraNonceMinerIdBytes = 1
    static let extraNonceMinerIdPos = extraNonceCounterBytes + extraNonceCounterBytes
    static let extraNonceRandomBytes = 3
    static let extraNonceRandomPos = extraNonceMinerIdPos + extraNonceMinerIdBytes
}
