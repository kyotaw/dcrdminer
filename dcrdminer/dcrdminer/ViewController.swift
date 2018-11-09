//
//  ViewController.swift
//  dcrdminer
//
//  Created by Kyota Watanabe on 2018/10/20.
//  Copyright © 2018 watanabe kyota. All rights reserved.
//

import UIKit

class ViewController: UIViewController, PoolDelegate, MinerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pool = Pool(host: "dcr-as.coinmine.pl", port: 2222, workerName: "bororon.worker", password: "pass")
        self.miner = Miner(id: 1)
        self.miner.delegate = self
        self.pool.subscribe(subscriber: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func receiveJob(job: PoolJob) {
        self.miner.mineHash(job: job)
    }
    
    // MinerDelegate
    func foundNonce(nonce: UInt32, extraNonce: UInt32, hash: String, job: PoolJob) {
        self.hashLabel.text = hash
        print("Nonce: " + Hex(num: nonce).str)
        print("ExtraNonce: " + Hex(num: extraNonce).str)
    }
    
    func receiveHashRate(hashRate: Float) {
        DispatchQueue.main.async {
            self.hashRateLabel.text = hashRate.description
        }
    }
    
    var pool: Pool!
    var miner: Miner!
    @IBOutlet weak var hashRateLabel: UILabel!
    @IBOutlet weak var hashLabel: UILabel!
}

