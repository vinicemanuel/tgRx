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

typealias Point = (x: Double,y: Double)

enum Side: String {
    case left = "⬅️"
    case right = "➡️"
    case down = "⬇️"
    case up = "⬆️"
    case straight = "⏹"
}

class ViewController: UIViewController {
    
    @IBOutlet weak var labelX: UILabel!
    @IBOutlet weak var labelY: UILabel!
    @IBOutlet weak var sideLabel: UILabel!
    
    private var publishPoint = BehaviorSubject<Point>(value: (0,0))
    private var subscribePoint: Observable<Point>!
    
    private var publishSide = BehaviorSubject<Side>(value: Side.straight)
    private var subscribeSide: Observable<Side>!
    private let manager = CMMotionManager()
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.manager.isDeviceMotionAvailable{
            self.manager.deviceMotionUpdateInterval = 0.3
            self.configPublish()
            self.configsubscribe()
        }
        
        self.sideLabel.text = Side.straight.rawValue
    }
    
    func configPublish(){
        self.manager.startDeviceMotionUpdates(to: OperationQueue.current ?? OperationQueue.main) { (motion, error) in
            if let motion = motion{
                let point = (motion.gravity.x, motion.gravity.y)
                self.publishPoint.onNext(point)
            }
        }
    }
    
    func configsubscribe(){
        self.subscribePoint = self.publishPoint.asObservable()
        let newPointObservable = self.subscribePoint.filter({ (value) -> Bool in
            return true
        })
        
        newPointObservable.subscribe {(value) in
                if let value = value.element{
                    print(value)
                    self.labelX.text = String(format: "%.2f",value.x)
                    self.labelY.text = String(format: "%.2f",value.y)
                }
            }.disposed(by: self.disposeBag)
    }
}

