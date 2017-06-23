//
//  InterfaceController.swift
//  AccelerateWatchExampleForWatch Extension
//
//  Created by HerrKaefer on 2017/6/23.
//  Copyright © 2017年 CocoaPods. All rights reserved.
//

import WatchKit
import Foundation

import AccelerateWatch

class InterfaceController: WKInterfaceController {

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        
        DSBuffer.test()
        vTest()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
