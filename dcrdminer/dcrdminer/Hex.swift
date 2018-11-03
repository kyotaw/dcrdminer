//
//  Hex.swift
//  dcrdminer
//
//  Created by Kyota Watanabe on 2018/11/03.
//  Copyright © 2018 watanabe kyota. All rights reserved.
//

import Foundation

class Hex {
    init(hexStr: String) {
        self.hexStr = hexStr
    }
    
    init(size: Int) {
        self.hexStr = String(repeating: "00", count: size)
    }
    
    var str: String {
        get { return self.hexStr }
    }
    
    lazy var bytes: [UInt8]? = {
        let bytesCount = self.hexStr.count / 2
        var bytes = [UInt8]()
        bytes.reserveCapacity(bytesCount)
        var index = self.hexStr.startIndex
        for _ in 0 ..< bytesCount {
            let nextIndex = self.hexStr.index(index, offsetBy: 2)
            if let b = UInt8(self.hexStr[index..<nextIndex], radix: 16) {
                bytes.append(b)
            } else {
                return nil
            }
            index = nextIndex
        }
        return bytes
    }()
    
    private func hexStrToBytes(hexStr: String) {
        
    }
    
    private let hexStr: String
}
