//
//  ViewController.swift
//  DebouncFunction
//
//  Created by Peter Ho on 2017-03-01.
//  Copyright © 2017 Peter Ho. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var debouncedSwitches: [DebouncedSwitch]!
    
    private var spinner: UIActivityIndicatorView?
    private var onOffCount = 0
    var debouncedFunction: (()->())?
    
    func debounce(delay: Int, queue: DispatchQueue, action: @escaping (() -> ())) -> ()->() {
        var lastFireTime = DispatchTime.now()
        print("lastFireTime = \(lastFireTime.rawValue)")
        let dispatchDelay = DispatchTimeInterval.milliseconds(delay)
        
        return {
            let dispatchTime: DispatchTime = lastFireTime + dispatchDelay
            queue.asyncAfter(deadline: dispatchTime, execute: {
                let when: DispatchTime = lastFireTime + dispatchDelay
                let now = DispatchTime.now()
                if now.rawValue >= when.rawValue {
                    lastFireTime = DispatchTime.now()
                    action()
                } else {
                    print("now(\(now.rawValue)) < when(\(when.rawValue))")
                }
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        debouncedFunction = debounce(delay: 5000, queue: DispatchQueue.main, action: {
            print("repeat \(Date().timeIntervalSinceReferenceDate)")
        })
        
        for s in debouncedSwitches {
            s.addTarget(self, action: #selector(onOff), for: .touchUpInside)
//            s.debouncedOnOffHandler =
        }
        
        self.spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        self.view.addSubview(self.spinner!)
        self.spinner!.center = CGPoint(x: self.view.frame.size.width / 2, y: self.view.frame.size.height / 2)
        self.spinner!.color = UIColor.blue
        self.spinner!.hidesWhenStopped = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func start(_ sender: Any) {
        DispatchQueue.global(qos: .background).async {
            for index in 1...100000 {
                print("Index - \(index)")
                self.debouncedFunction?()
            }
        }
    }

    @IBAction func calculate(_ sender: Any) {
        let lastFireTime = DispatchTime.now()
        print("lastFireTime = \(lastFireTime.rawValue)")
        let dispatchDelay = DispatchTimeInterval.milliseconds(1000)
        let when = lastFireTime + dispatchDelay
        let now = DispatchTime.now()
        print("now = \(now.rawValue), when = \(when.rawValue)")
    }
    
    @IBAction func startManually(_ sender: Any) {
        debouncedFunction?()
    }
    @IBAction func onOff(_ sender: DebouncedSwitch) {
        if self.onOffCount == 0 {
            self.spinner!.startAnimating()
        }
        self.onOffCount += 1
//        for s in debouncedSwitches {
//            s.isEnabled = false
//        }
        sender.isEnabled = false
        let dispatchTime = DispatchTime.now() + DispatchTimeInterval.milliseconds(1000)
        DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
//            for s in self.debouncedSwitches {
//                s.isEnabled = true
//            }
            sender.isEnabled = true
            self.onOffCount -= 1
            if self.onOffCount == 0 {
                self.spinner!.stopAnimating()
            }
        })
        print("Switch(\(sender)) is pressed.")
    }
}

