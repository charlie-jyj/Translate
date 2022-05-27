//
//  NotificationService.swift
//  NotificationExtension
//
//  Created by 정유진 on 2022/05/27.
//

import UserNotifications
import Firebase
import UIKit

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...
            let imageData = request.content.userInfo["fcm_options"] as! [String : Any]
            
            guard let imageURLString = imageData["image"] as? String else {
                contentHandler(bestAttemptContent)
                return
            }
            
            let fileManager = FileManager.default
            let tmpSubFolderName = ProcessInfo.processInfo.globallyUniqueString
            let tmpSubFolderURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(tmpSubFolderName, isDirectory: true)
            
            bestAttemptContent.body = "tempSubFolderURL"+tmpSubFolderURL.path
            
            do {
               
                let fileURL = tmpSubFolderURL.appendingPathComponent(imageURLString)
               
                
                try fileManager.createDirectory(at: tmpSubFolderURL, withIntermediateDirectories: true, attributes: nil)
                let imageFileIdentifier = "pushImg.jpg"
                let imageFileURL = tmpSubFolderURL.appendingPathComponent(imageFileIdentifier)
                
                guard let imageURL = URL(string: imageURLString),
                      let imageData = try? Data(contentsOf: imageURL) else {
                    contentHandler(bestAttemptContent)
                    return
                }
                
                bestAttemptContent.body = "imageURLString"+imageURLString
                bestAttemptContent.body = "fileURL"+fileURL.description
                
                try imageData.write(to: imageFileURL)
        
                if fileManager.fileExists(atPath: imageFileURL.path){
                    let attachment = try UNNotificationAttachment.init(identifier: imageFileIdentifier, url: imageFileURL, options: nil)
                    bestAttemptContent.attachments = [ attachment ]
                    bestAttemptContent.body = "file Exists and attachment initialized"
                } else {
                    bestAttemptContent.body = "file not exist"
                }

            } catch {
                bestAttemptContent.body = "something is getting wrong"
                contentHandler(bestAttemptContent)
                return
            }
            
            Messaging.serviceExtension().populateNotificationContent(bestAttemptContent, withContentHandler: self.contentHandler!)
                        
            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}

extension UNNotificationAttachment {
    
    static func saveImageToDisk(fileIdentifier: String, data: NSData, options: [NSObject : AnyObject]?) -> UNNotificationAttachment? {
        let fileManager = FileManager.default
        let folderName = ProcessInfo.processInfo.globallyUniqueString
        let folderURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(folderName, isDirectory: true)
        
        do {
            try fileManager.createDirectory(at: folderURL!, withIntermediateDirectories: true, attributes: nil)
            let fileURL = folderURL?.appendingPathComponent(fileIdentifier)
            try data.write(to: fileURL!, options: [])
            let attachment = try UNNotificationAttachment(identifier: fileIdentifier, url: fileURL!, options: options)
            return attachment
        } catch let error {
            print("error \(error)")
        }
        
        return nil
    }
}

