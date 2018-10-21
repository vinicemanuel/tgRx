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
    @IBOutlet weak var phoneSideLabel: UILabel!
    @IBOutlet weak var gameSideLabel: UILabel!
    @IBOutlet weak var gameStatusLabel: UILabel!
    
    private let tiltLimitSup = 0.4
    private let tiltLimitInf = -0.4
    
    private var sequence: [String] = ["Left","Right","Left","Down","Left"]
    
    private var obsInteraction: Observable<String>!
    private var obsSequence: Observable<String>!
    private var obsTogether: Observable<(String, String)>!
    
    var disposeBag = DisposeBag()
    let coreMotionManager = CMMotionManager.rx.manager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.gameSideLabel.text = ""
        self.phoneSideLabel.text = ""
        self.gameStatusLabel.text = ""
        
        self.configGameObs()
        self.runGameObs()
    }
    
    func startUserInteraction(){
        obsTogether.subscribe(onNext: { [unowned self] (element) in
            print(element)
            self.phoneSideLabel.text = element.1
            if element.0 != element.1{
                self.gameSideLabel.text = "Perdeu!"
                self.disposeBag = DisposeBag()
            }
        }, onError: nil, onCompleted: { [unowned self] in
            print("fim game")
            self.gameSideLabel.text = "Ganhou!"
            self.phoneSideLabel.text = ""
            }, onDisposed: nil)
            .disposed(by: disposeBag)
    }
    
    func runGameObs(){
        self.obsSequence.subscribe( onNext: { [unowned self] (side) in
            print(side)
            self.gameSideLabel.text = side
            }, onError: nil, onCompleted: { [unowned self] in
                self.gameSideLabel.text = ""
                print("fim")
                self.startUserInteraction()
        }, onDisposed: nil)
            .disposed(by: disposeBag)
        
//        obsInteraction.subscribe({ [unowned self] side in
//            self.phoneSideLabel.text = side.element
//        }).disposed(by: disposeBag)
        
    }
    
    func configGameObs(){
        self.obsSequence = Observable.zip(Observable.from(sequence), Observable<Int>.interval(RxTimeInterval(1), scheduler: MainScheduler.instance))
            .map({ (info) in
                return info.0
            })
        
        
        self.obsInteraction = self.coreMotionManager
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
                    return "Up"
                }else if deviceMotion.gravity.y < self.tiltLimitInf{
                    return "Down"
                }
                return "straight"
            })
        .distinctUntilChanged()
        
        self.obsTogether = Observable.zip(obsSequence, obsInteraction)
    }
}

