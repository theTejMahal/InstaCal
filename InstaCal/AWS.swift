//
//  AWS.swift
//  InstaCal
//
//  Created by Jet on 10/22/16.
//  Copyright © 2016 InstaCal. All rights reserved.
//

import AWSS3

class AWS {
    
    // Identifiers
    let S3BucketName = "ambivio-images"
    let CognitoPoolID = "us-east-1:53ca6c6f-1273-4d73-af1e-5ff01edf0cb6"
    let Region = AWSRegionType.usEast1
    
    init() {
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: Region,
                                                                identityPoolId: CognitoPoolID)
        let configuration = AWSServiceConfiguration(region: Region, credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }
    
    func uploadImage(imageToUpload: UIImage, imageName: String, folder: String, completion: @escaping (_ status: String, _ url: String?) -> ()) {
        
        // Create a local image that we can use to upload to s3
        let ext = "jpeg"
        let path: NSString = NSTemporaryDirectory().appending("\(imageName).\(ext)") as NSString
        let imageData: NSData = UIImageJPEGRepresentation(imageToUpload, 0.5)! as NSData
        imageData.write(toFile: path as String, atomically: true)
        
        // Create image URL
        let imageURL: NSURL = NSURL(fileURLWithPath: path as String)
        
        // Prepare image uploader
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest?.body = imageURL as URL!
        uploadRequest?.key = "\(folder)/" + ProcessInfo.processInfo.globallyUniqueString + "." + ext
        uploadRequest?.bucket = S3BucketName
        uploadRequest?.contentType = "image/" + ext
        
        uploadToS3(uploadRequest: uploadRequest!, completion: completion)
    }
    
    func uploadToS3(uploadRequest: AWSS3TransferManagerUploadRequest, completion: @escaping (_ status: String, _ url: String?) -> ()) {
        let transferManager = AWSS3TransferManager.default()
        transferManager?.upload(uploadRequest).continue ({ (task) -> AnyObject! in
            
            guard task.error == nil else {
                print("Upload failed (\(task.error))")
                completion("error", nil)
                return nil
            }
            
            guard task.exception == nil else {
                print("Upload failed (\(task.exception))")
                completion("error", nil)
                return nil
            }
            
            guard task.result != nil else {
                print("Unexpected empty result")
                completion("error", nil)
                return nil
            }
            
            // Return image URL
            let s3URL = "https://media.ambivio.com/\(uploadRequest.key!)"
            print("Uploaded to:\n\(s3URL)")
            completion("success", s3URL)
            return nil
        })
        
        
    }
    
    
    func applicationDocumentsDirectory()-> NSURL {
        return FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).last! as NSURL
    }
    
}
