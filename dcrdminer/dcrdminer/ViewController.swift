//
//  ViewController.swift
//  dcrdminer
//
//  Created by 渡部郷太 on 2018/10/20.
//  Copyright © 2018 watanabe kyota. All rights reserved.
//

import UIKit

class ViewController: UIViewController, StratumDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.stratum = Stratum(host: "dcr-as.coinmine.pl", port: 2222, delegate: self)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func receiveData(dataString: String) {
        print(dataString)
    }
    
    func receiveMessage(message: SubscriveResult) {
        print(message)
    }
    
    func receiveMessage(message: NotifyMethod) {
        print(message)
    }
    
    func receiveMessage(message: SetDifficultyMethod) {
        print(message)
    }
    
    var stratum: Stratum!
}

