//
//  ViewController.swift
//  ExemploTG
//
//  Created by vinicius emanuel on 09/10/2018.
//  Copyright © 2018 vinicius emanuel. All rights reserved.
//

import UIKit
import RxSwift
import CoreMotion

class ViewController: UIViewController {
    
    let motionManager = CMMotionManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.motionManager.gyroUpdateInterval = 0.3
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.motionManager.startGyroUpdates(to: OperationQueue.current ?? OperationQueue.main) { (data, error) in
            if let data = data{
                print(data)
            }
        }
    }
}

