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
        self._hexStr = hexStr
        self._bytes = [UInt8]()
        self._bytes = self.hexStrToBytes(hexStr: hexStr)
    }
    
    init(size: Int) {
        self._hexStr = String(repeating: "00", count: size)
        self._bytes = [UInt8]()
        self._bytes = self.hexStrToBytes(hexStr: self._hexStr)
    }
    
    init(num: UInt32) {
        self._hexStr = String(format: "%02x", num)
        self._bytes = [UInt8]()
        self._bytes = self.hexStrToBytes(hexStr: self._hexStr )
    }
    
    var str: String {
        return self._hexStr
    }
    
    var bytes: [UInt8] {
        return self._bytes
    }
    
    private func hexStrToBytes(hexStr: String) -> [UInt8] {
        let bytesCount = hexStr.count / 2
        var bytes = [UInt8]()
        bytes.reserveCapacity(bytesCount)
        var index = hexStr.startIndex
        for _ in 0 ..< bytesCount {
            let nextIndex = hexStr.index(index, offsetBy: 2)
            if let b = UInt8(hexStr[index..<nextIndex], radix: 16) {
                bytes.append(b)
            } else {
                return []
            }
            index = nextIndex
        }
        return bytes
    }
    
    private var _hexStr: String
    private var _bytes: [UInt8]
}
