//
//  ImagePreviewVC.swift
//  InstaCal
//
//  Created by Jet on 10/22/16.
//  Copyright © 2016 InstaCal. All rights reserved.
//

import UIKit
import Alamofire

class ImagePreviewVC: UIViewController {
    
    var capturedImage: UIImage!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var previewImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        previewImageView.image = capturedImage
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        previewImageView.image = nil
    }
    
    @IBAction func RetakeAction() {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func confirmAction() {
        let imageName = "data"
        AWS().uploadImage(imageToUpload: capturedImage, imageName: imageName, folder: "InstaCal") { status, awsURL in
            guard let url = awsURL else{
                print(status)
                return
            }
            print(url)
            self.parse(urlin: url)
        }
    }
    
    // data detection
    func NSTextCheckingTypesFromUIDataDetectorTypes(dataDetectorType: UIDataDetectorTypes) -> NSTextCheckingResult.CheckingType
    
    {
        var textCheckingType: NSTextCheckingResult.CheckingType = []
        
        if dataDetectorType.contains(.address) {
            textCheckingType.insert(.address)
        }
        
        if dataDetectorType.contains(.calendarEvent) {
            textCheckingType.insert(.date)
        }
        
        if dataDetectorType.contains(.link) {
            textCheckingType.insert(.link)
        }
        
        if dataDetectorType.contains(.phoneNumber) {
            textCheckingType.insert(.phoneNumber)
        }
        
        return textCheckingType
    }
    

    func parse(urlin: String) {
        let parameters = [
            "Url": urlin
        ]
        let headers = [
             "Ocp-Apim-Subscription-Key": "0df2d56a494245418506045edcab6e6b"
        ]
        Alamofire.request("https://api.projectoxford.ai/vision/v1.0/ocr", method: .post , parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .responseJSON { response in
                guard let data = response.result.value as? [String: Any],
                let arr = data["regions"] as? [[String: Any]] else{
                    print(response)
                    return
                }
                var result = ""
                for region in arr{
                    guard let lines = region["lines"] as? [[String: Any]] else{
                        print("lines error")
                        return
                    }
                    for line in lines{
                        guard let words = line["words"] as? [[String: Any]] else{
                            print("words error")
                            return
                        }
                        for word in words{
                            guard let text = word["text"] as? String else{
                                print("text error")
                                return
                            }
                            result+=text+" "
                        }
                        
                    }
                }
                print(arr)
                
                
                self.containerView.isHidden = false
                self.textView.text = result
                
                
                let types: NSTextCheckingResult.CheckingType = .link
                var URLStrings = [NSURL]()
                let detector = try? NSDataDetector(types: types.rawValue)
                let matches = detector!.matches(in: result, options: .reportCompletion, range: NSMakeRange(0, result.characters.count))
                
                for match in matches {
                    print(match.url!)
                    URLStrings.append(match.url! as NSURL)
                } 
                print(URLStrings)
                
        }
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
