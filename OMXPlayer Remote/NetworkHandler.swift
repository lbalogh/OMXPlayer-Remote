//
//  NetworkHandler.swift
//  OMXPlayer Remote
//
//  Created by Ludovic Balogh on 30.08.15.
//  Copyright © 2015 Ludovic Balogh. All rights reserved.
//

import Foundation

protocol NetworkHandlerDelegate {
    func dataReceived(data: NSData)
}

class NetworkHandler {
    
    var delegate:NetworkHandlerDelegate!
    
    func sendData(host: String, dataDictonary: AnyObject)
    {
        let data: NSData
        do
        {
            // Convert the "dataDictonary" array to JSON data
            data = try NSJSONSerialization.dataWithJSONObject(dataDictonary, options: [])
        }
        catch let error as NSError
        {
            print("JSON error : \(error)")
            return
        }

        let url = NSURL(string: host)!
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
        // Send the JSON data to the player
        var uploadTask = NSURLSessionUploadTask()
        uploadTask = session.uploadTaskWithRequest(request, fromData: data)
            {
                (responseData, response, error) in
                // Response received from the player
                if responseData?.length > 0 && self.delegate != nil
                {
                    self.delegate.dataReceived(responseData!)
                }
        }
        
        uploadTask.resume()
    }
}