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
    
    var pool: Pool!
    var miner: Miner!
}

