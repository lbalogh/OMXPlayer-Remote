//
//  FileTableViewController.swift
//  OMXPlayer Remote
//
//  Created by Ludovic Balogh on 01.08.15.
//  Copyright © 2015 Ludovic Balogh. All rights reserved.
//

import UIKit

protocol FileTableViewControllerDelegate {
    func updateFileList(path: String)
    func playFile(path: String)
    func deleteFile(path: String)
    func deleteFolder(path: String)
}

class FileTableViewController: UITableViewController {
    
    var delegate:FileTableViewControllerDelegate!
    var fileList: NSDictionary?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadData:", name: kReloadFileListNotification, object: nil)
        self.refreshControl?.addTarget(self, action: "refreshCurrentDirectory:", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    override func viewDidDisappear(animated: Bool)
    {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: kReloadFileListNotification, object: nil)
    }
    
    func reloadData(notification: NSNotification)
    {
        self.fileList = notification.object as? NSDictionary
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    func refreshCurrentDirectory(sender:AnyObject)
    {
        if (self.fileList != nil)
        {
            self.delegate.updateFileList(fileList!.objectForKey(kPathKey) as! String)
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        // Section 1 contains directories, and section 2 contains files
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (self.fileList != nil)
        {
            if section == 0
            {
                let dirs = self.fileList!.objectForKey(kDirsKey) as! NSArray
                return dirs.count + 1
            }
            else
            {
                let files = self.fileList!.objectForKey(kFilesKey)  as! NSArray
                return files.count
            }
        }
        else
        {
            return 0;
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        // Configure the cell depending if it's a directory or a file
        if indexPath.section == 0
        {
            // It's a directory
            if indexPath.row != 0
            {
                let dirs = self.fileList!.objectForKey(kDirsKey) as! NSArray
                cell.textLabel!.text = dirs.objectAtIndex(indexPath.row - 1) as? String
                cell.imageView!.image = UIImage(named: "folder.png")
            }
            else
            {
                cell.textLabel!.text = "...";
                cell.imageView!.image = UIImage(named: "folder.png")
            }
        }
        else
        {
            // It's a file
            let files = self.fileList!.objectForKey(kFilesKey)  as! NSArray
            cell.textLabel!.text = files.objectAtIndex(indexPath.row) as? String
            cell.imageView!.image = UIImage(named: "movie.png")
        }

        
        cell.textLabel!.font = cell.textLabel!.font.fontWithSize(12)

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        let path = fileList!.objectForKey(kPathKey) as! String
        
        if indexPath.section == 0
        {
            if indexPath.row != 0
            {
                // Navigate to selected directory
                self.delegate.updateFileList("\(path)/\(cell.textLabel!.text!)")
            }
            else
            {
                // Navigate to parent directory
                let range = path.rangeOfString("/", options: NSStringCompareOptions.BackwardsSearch)!
                self.delegate.updateFileList(path.substringToIndex(range.startIndex))
            }
        }
        else
        {
            // Play selected file
            self.delegate.playFile("\(path)/\(cell.textLabel!.text!)")
            self.navigationController?.popViewControllerAnimated(true)
        }
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return indexPath.section != 0 || ( indexPath.section == 0 && indexPath.row != 0)
    }

    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if editingStyle == .Delete
        {
            // Ask the user if he really wants to delete the selected item
            let cell = tableView.cellForRowAtIndexPath(indexPath)!
            let alert = UIAlertController(title: "Delete", message:"Are you sure you want to delete \(cell.textLabel!.text!)", preferredStyle: .Alert)
            let actionYes = UIAlertAction(title: "Yes", style: .Default)
            { _ in
                // If "Yes" is selected, proceed with the deletion
                let path = self.fileList!.objectForKey(kPathKey) as! String
                if indexPath.section == 0
                {
                    // Delete the selected directory
                    let dirs = self.fileList!.objectForKey(kDirsKey) as! NSMutableArray
                    dirs.removeObjectAtIndex(indexPath.row - 1)
                    self.delegate.deleteFolder("\(path)/\(cell.textLabel!.text!)")
                }
                else
                {
                    // Delete the selected file
                    let files = self.fileList!.objectForKey(kFilesKey)  as! NSMutableArray
                    files.removeObjectAtIndex(indexPath.row)
                    self.delegate.deleteFile("\(path)/\(cell.textLabel!.text!)")
                }

                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }

            alert.addAction(actionYes)
            alert.addAction(UIAlertAction(title: "Cancel", style: .Default) { _ in })
            
            presentViewController(alert, animated: true, completion: nil)
        }
    }
}
