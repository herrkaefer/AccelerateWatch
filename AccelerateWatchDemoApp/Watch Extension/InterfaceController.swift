//
//  InterfaceController.swift
//  Watch Extension
//
//  Created by HerrKaefer on 16/6/27.
//  Copyright © 2016年 Herrkaefer. All rights reserved.
//

import WatchKit
import Foundation


/// :nodoc:
class InterfaceController: WKInterfaceController {

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        DSBuffer.test()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
