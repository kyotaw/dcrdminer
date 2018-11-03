//
//  ExtraNonceCounter.swift
//  dcrdminer
//
//  Created by Kyota Watanabe on 2018/11/03.
//  Copyright © 2018 watanabe kyota. All rights reserved.
//

import Foundation

class NonceCounter {
    init(value: UInt32) {
        self.nonce = value
    }
    
    func rollOver() {
        if self.nonce == UInt32.max {
            self.nonce = 0
        } else {
            self.nonce += 1
        }
    }
    
    var bytes: [UInt8] {
        var bytes = [UInt8]()
        bytes.append(UInt8((self.nonce & 0xFF000000) >> 24))
        bytes.append(UInt8((self.nonce & 0x00FF0000) >> 16))
        bytes.append(UInt8((self.nonce & 0x0000FF00) >> 8))
        bytes.append(UInt8(self.nonce & 0x000000FF))
        return bytes
    }
    
    var nonce: UInt32
}
