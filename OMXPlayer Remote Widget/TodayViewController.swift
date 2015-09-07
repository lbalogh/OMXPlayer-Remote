//
//  TodayViewController.swift
//  OMXPlayer Remote Widget
//
//  Created by Ludovic Balogh on 30.08.15.
//  Copyright © 2015 Ludovic Balogh. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    let networkHandler = NetworkHandler()

    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void))
    {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        completionHandler(NCUpdateResult.NewData)
    }
    
    @IBAction func pauseButtonPressed(sender: AnyObject)
    {
        self.sendCommandToPlayer([kCommandKey: kPauseCommand])
    }
        
    @IBAction func seekBackwardButtonPressed(sender: AnyObject)
    {
        self.sendCommandToPlayer([kCommandKey: kSeekBackwardCommand])
    }
    
    @IBAction func seekForwardButtonPressed(sender: AnyObject)
    {
        self.sendCommandToPlayer([kCommandKey: kSeekForwardCommand])
    }
    
    @IBAction func seekFastBackwardButtonPressed(sender: AnyObject)
    {
        self.sendCommandToPlayer([kCommandKey: kSeekFastBackwardCommand])
    }
    
    @IBAction func seekFastForwardButtonPressed(sender: AnyObject)
    {
        self.sendCommandToPlayer([kCommandKey: kSeekFastForwardCommand])
    }
    
    func sendCommandToPlayer(command: AnyObject)
    {
        let ipAddress = NSUserDefaults(suiteName: kAppGroupName)!.stringForKey(kHostIpAddressKey)
        let port = NSUserDefaults(suiteName: kAppGroupName)!.stringForKey(kHostPortKey)
        
        if ipAddress!.isEmpty || port!.isEmpty
        {
            return
        }
        
        networkHandler.sendData("http://\(ipAddress!):\(port!)", dataDictonary: command)
    }
}
