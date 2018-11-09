//
//  Blake256.swift
//  dcrdminer
//
//  Created by Kyota Watanabe on 2018/11/03.
//  Copyright © 2018 watanabe kyota. All rights reserved.
//

import Foundation

class Blake256 {
    init(round: Int32) {
        sph_blake256_set_rounds(round)
        self.output = UnsafeMutableRawPointer.allocate(byteCount: 32, alignment: 1)
    }
    
    deinit {
        self.output.deallocate()
    }
    
    func hash(input: [UInt8]) -> String {
        var ctx = sph_blake256_context()
        sph_blake256_init(&ctx)
        sph_blake256(&ctx, input, BlockHeader.blockHeaderBytes)
        sph_blake256_close(&ctx, output)
        let bytes = output.bindMemory(to: UInt8.self, capacity: 32)
        var hex = ""
        for i in 0..<32 {
            hex += String(format: "%02hhx", bytes[i])
        }
        return hex
    }
    
    var output: UnsafeMutableRawPointer
}
