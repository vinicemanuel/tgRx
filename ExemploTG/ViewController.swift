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
import RxCoreMotion

class ViewController: UIViewController {
    
    @IBOutlet weak var labelX: UILabel!
    @IBOutlet weak var labelY: UILabel!
    @IBOutlet weak var phoneSide: UILabel!
    
    private let tiltLimitSup = 0.4
    private let tiltLimitInf = -0.4
    
    let disposeBag = DisposeBag()
    let coreMotionManager = CMMotionManager.rx.manager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.coreMotionManager
            .flatMapFirst { manager in
                manager.deviceMotion ?? Observable.empty()
            }
            .observeOn(MainScheduler.instance)
            .filter({ [unowned self] (deviceMotion) -> Bool in
                //inclinação correta em X
                if ((deviceMotion.gravity.x <= self.tiltLimitInf || deviceMotion.gravity.x >= self.tiltLimitSup) && (deviceMotion.gravity.y > self.tiltLimitInf && deviceMotion.gravity.y < self.tiltLimitSup)){
                    return true
                //inclinação correta em Y
                }else if ((deviceMotion.gravity.y <= self.tiltLimitInf || deviceMotion.gravity.y >= self.tiltLimitSup) && (deviceMotion.gravity.x > self.tiltLimitInf && deviceMotion.gravity.x < self.tiltLimitSup)){
                    return true
                }else if ((deviceMotion.gravity.y > self.tiltLimitInf && deviceMotion.gravity.y < self.tiltLimitSup) && (deviceMotion.gravity.x > self.tiltLimitInf && deviceMotion.gravity.x < self.tiltLimitSup)){
                    return true
                }
                return false
            })
            .map({ [unowned self] (deviceMotion) -> String in
                
                self.labelX.text = "x: \(String(format: "%.1f", deviceMotion.gravity.x))"
                self.labelY.text = "y: \(String(format: "%.1f", deviceMotion.gravity.y))"
                
                if deviceMotion.gravity.x < self.tiltLimitInf{
                    return "Left"
                }else if deviceMotion.gravity.x > self.tiltLimitSup{
                    return "Right"
                }else if deviceMotion.gravity.y > self.tiltLimitSup{
                    return "Dwon"
                }else if deviceMotion.gravity.y < self.tiltLimitInf{
                    return "Up"
                }
                return "straight"
            })
            .subscribe({ [unowned self] side in
                self.phoneSide.text = side.element
            })
            .disposed(by: disposeBag)
    }
}

