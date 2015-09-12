//
//  ViewController.swift
//  OMXPlayer Remote
//
//  Created by Ludovic Balogh on 01.08.15.
//  Copyright © 2015 Ludovic Balogh. All rights reserved.
//

import UIKit
import WatchConnectivity

class ViewController: UIViewController, WCSessionDelegate, NetworkHandlerDelegate, FileTableViewControllerDelegate {

    @IBOutlet weak var ipAddressTextField: UITextField!
    @IBOutlet weak var portTextField: UITextField!
    @IBOutlet weak var browseButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var seekBackwardButton: UIButton!
    @IBOutlet weak var seekForwardButton: UIButton!
    @IBOutlet weak var seekFastBackwardButton: UIButton!
    @IBOutlet weak var seekFastForwardButton: UIButton!
    
    let networkHandler = NetworkHandler()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Init communication with the watch
        if WCSession.isSupported()
        {
            let session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
            
            print("WCSession initialized")
        }
        
        // Set the networkHandler delegate to self to receive responses from the server
        networkHandler.delegate = self

        self.ipAddressTextField.text = NSUserDefaults(suiteName: kAppGroupIdentifier)!.stringForKey(kHostIpAddressKey)
        self.portTextField.text = NSUserDefaults(suiteName: kAppGroupIdentifier)!.stringForKey(kHostPortKey)

        // Register to application state change notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector:Selector("applicationDidBecomeActive"), name:UIApplicationDidBecomeActiveNotification, object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:Selector("applicationWillTerminate"), name:UIApplicationWillTerminateNotification, object:nil)
        
        self.applicationDidBecomeActive()
    }
    
    func applicationDidBecomeActive()
    {
        print("Application did became active")

        // Check if a movie is playing, and refresh title and media controls
        self.sendCommandToPlayer([kCommandKey: kIsPlayingCommand])
    }
    
    func applicationWillTerminate()
    {
        print("Application will terminate")
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
        
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.destinationViewController is FileTableViewController
        {
            let fileTableViewController = segue.destinationViewController as! FileTableViewController
            fileTableViewController.delegate = self
        }
    }
    
    // MARK:WCSessionDelegate
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject])
    {
        print("Message received from the watch : \(message)")
        self.sendCommandToPlayer(message)
    }
    
    // MARK:FileTableViewControllerDelegate
    
    func updateFileList(path: String)
    {
        self.sendCommandToPlayer([kCommandKey: kListDirCommand, kPathKey: path])
    }
    
    func playFile(path: String)
    {
        self.title = "\((path as NSString).lastPathComponent)"
        self.enableMediaControls(true)
        self.sendCommandToPlayer([kCommandKey: kPlayCommand, kPathKey: path])
    }
    
    func deleteFile(path: String)
    {
        self.sendCommandToPlayer([kCommandKey: kDeleteFileCommand, kPathKey: path])
    }
    
    func deleteFolder(path: String)
    {
        self.sendCommandToPlayer([kCommandKey: kDeleteFolderCommand, kPathKey: path])
    }
    
    // MARK:IBActions

    @IBAction func ipAddressTextFieldEdited(sender: AnyObject)
    {
        NSUserDefaults(suiteName: kAppGroupIdentifier)!.setValue(self.ipAddressTextField.text, forKey: kHostIpAddressKey)
    }

    @IBAction func portTextFieldEdited(sender: AnyObject)
    {
        NSUserDefaults(suiteName: kAppGroupIdentifier)!.setValue(self.portTextField.text, forKey: kHostPortKey)
    }
    
    @IBAction func browseButtonPressed(sender: AnyObject)
    {
        self.performSegueWithIdentifier("toFileTableViewController", sender: self.browseButton)
        self.sendCommandToPlayer([kCommandKey: kListDirCommand])
    }
    
    @IBAction func pauseButtonPressed(sender: AnyObject)
    {
        self.sendCommandToPlayer([kCommandKey: kPauseCommand])
    }

    @IBAction func stopButtonPressed(sender: AnyObject)
    {
        self.title = nil
        self.enableMediaControls(false)
        self.sendCommandToPlayer([kCommandKey: kStopCommand])
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
    
    @IBAction func refreshButtonPressed(sender: AnyObject)
    {
        // Check if a movie is playing
        self.sendCommandToPlayer([kCommandKey: kIsPlayingCommand])
    }
    
    @IBAction func subtitleButtonPressed(sender: AnyObject)
    {
        let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        actionSheetController.addAction(UIAlertAction(title: "Next subtitle stream", style: UIAlertActionStyle.Default, handler: { (actionSheetController) -> Void in
            self.sendCommandToPlayer([kCommandKey: kNextSubtitleStreamCommand])
        }))
        
        actionSheetController.addAction(UIAlertAction(title: "Previous subtitle stream", style: UIAlertActionStyle.Default, handler: { (actionSheetController) -> Void in
            self.sendCommandToPlayer([kCommandKey: kPreviousSubtitleStreamCommand])
        }))
        
        actionSheetController.addAction(UIAlertAction(title: "Delay subtitle (+ 250ms)", style: UIAlertActionStyle.Default, handler: { (actionSheetController) -> Void in
            self.sendCommandToPlayer([kCommandKey: kIncreaseSubtitleDelayCommand])
        }))
        
        actionSheetController.addAction(UIAlertAction(title: "Delay subtitle (- 250ms)", style: UIAlertActionStyle.Default, handler: { (actionSheetController) -> Void in
            self.sendCommandToPlayer([kCommandKey: kDecreaseSubtitleDelayCommand])
        }))
        
        actionSheetController.addAction( UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        presentViewController(actionSheetController, animated: true, completion: nil)
    }
    
    @IBAction func actionButtonPressed(sender: AnyObject)
    {
        let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        actionSheetController.addAction(UIAlertAction(title: "Reboot", style: UIAlertActionStyle.Default, handler: { (actionSheetController) -> Void in
            self.title = nil
            self.enableMediaControls(false)
            self.sendCommandToPlayer([kCommandKey: kRebootCommand])
        }))

        actionSheetController.addAction(UIAlertAction(title: "Poweroff", style: UIAlertActionStyle.Default, handler: { (actionSheetController) -> Void in
            self.title = nil
            self.enableMediaControls(false)
            self.sendCommandToPlayer([kCommandKey: kPoweroffCommand])
        }))
        
        actionSheetController.addAction( UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        presentViewController(actionSheetController, animated: true, completion: nil)
    }

    @IBAction func swipedUpWithOneFinger(sender: AnyObject)
    {
        self.sendCommandToPlayer([kCommandKey: kIncreaseSubtitleDelayCommand])
    }
    
    @IBAction func swipedDownWithOneFinger(sender: AnyObject)
    {
        self.sendCommandToPlayer([kCommandKey: kDecreaseSubtitleDelayCommand])
    }

    // MARK:Networking
    
    func sendCommandToPlayer(command: AnyObject)
    {
        if self.ipAddressTextField.text!.isEmpty || self.portTextField.text!.isEmpty
        {
            return
        }

        print("Sending command to player : \(command)")
        networkHandler.sendData("http://\(self.ipAddressTextField.text!):\(self.portTextField.text!)", dataDictonary: command)
    }
    
    func dataReceived(data: NSData)
    {
        var dict: NSDictionary
        do
        {
            // Convert the response received from JSON data to NSDictionary
            dict = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
        }
        catch
        {
            print("JSON error : \(error)")
            return
        }
        
        print("Data received from player : \(dict)")
        
        // Process received data in main queue (because UI updates must be done in main queue)
        dispatch_async(dispatch_get_main_queue())
        {
            switch dict.objectForKey(kCommandKey) as! String
            {
            case kListDirCommand:
                NSNotificationCenter.defaultCenter().postNotificationName(kReloadFileListNotification, object: dict)
            case kPlayingFinishedCommand:
                self.title = nil
                self.enableMediaControls(false)
            case kIsPlayingCommand:
                let path = dict.objectForKey(kPathKey) as! NSString
                self.title = path.length > 0 ? "Playing : \(path.lastPathComponent)" : nil
                self.enableMediaControls(path.length > 0)
            default:
                print("Unknown command received from player : \(dict.objectForKey(kCommandKey))")
            }
        }
    }
    
    // MARK:Helper functions
    
    func enableMediaControls(enabled: Bool)
    {
        self.pauseButton.enabled = enabled
        self.seekBackwardButton.enabled = enabled
        self.seekForwardButton.enabled = enabled
        self.seekFastBackwardButton.enabled = enabled
        self.seekFastForwardButton.enabled = enabled
        self.stopButton.enabled = enabled
    }
}

