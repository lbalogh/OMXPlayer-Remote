//
//  InterfaceController.swift
//  OMXPlayer Remote WatchKit Extension
//
//  Created by Ludovic Balogh on 01.08.15.
//  Copyright © 2015 Ludovic Balogh. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity;

class InterfaceController: WKInterfaceController {

    override func awakeWithContext(context: AnyObject?)
    {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate()
    {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate()
    {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    // MARK:IBActions
    
    @IBAction func pauseButtonPressed()
    {
        self.sendMessageToPhone(kPauseCommand)
    }
    
    @IBAction func seekBackwardButtonPressed()
    {
        self.sendMessageToPhone(kSeekBackwardCommand)
    }
    
    
    @IBAction func seekForwardButtonPressed()
    {
        self.sendMessageToPhone(kSeekForwardCommand)
    }
    
    @IBAction func seekFastBackwardButtonPressed()
    {
        self.sendMessageToPhone(kSeekFastBackwardCommand)
    }
    
    @IBAction func seekFastForwardButtonPressed()
    {
        self.sendMessageToPhone(kSeekFastForwardCommand)
    }
    
    // MARK:Helpers
    
    func sendMessageToPhone(command: String)
    {
        print("Sending message to phone : \(command)");
        WCSession.defaultSession().sendMessage([kCommandKey: command], replyHandler: nil, errorHandler: nil)
    }
}
