//
//  ImagePreviewVC.swift
//  InstaCal
//
//  Created by Jet on 10/22/16.
//  Copyright © 2016 InstaCal. All rights reserved.
//

import UIKit
import Alamofire
import EventKit
import QuartzCore

class ImagePreviewVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var confirmButton: UIButton!
    var capturedImage: UIImage!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var previewImageView: UIImageView!

    
    @IBOutlet weak var eventTitle: UITextField!
    
    
    @IBOutlet weak var startDay: UITextField!
    @IBOutlet weak var startMonth: UITextField!
    @IBOutlet weak var startYear: UITextField!
    @IBOutlet weak var startTime: UITextField!
    
    @IBOutlet weak var endMonth: UITextField!
    @IBOutlet weak var endDay: UITextField!
    @IBOutlet weak var endYear: UITextField!
    @IBOutlet weak var endTime: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        containerView.layer.cornerRadius = 5
        containerView.layer.masksToBounds = true
        confirmButton.layer.cornerRadius = 5
        confirmButton.layer.masksToBounds = true
        previewImageView.image = capturedImage
        self.eventTitle.delegate = self
        self.startDay.delegate = self
        self.startMonth.delegate = self
        self.startYear.delegate = self
        self.startTime.delegate = self
        self.endDay.delegate = self
        self.endMonth.delegate = self
        self.endYear.delegate = self
        self.endTime.delegate = self
    }

    func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
        eventTitle.resignFirstResponder()
    }
   
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        previewImageView.image = nil
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    
    // MARK: Actions
    
    
    @IBAction func submittedAction() {
        
        let store = EKEventStore()
        store.requestAccess(to: .event) {(granted, error) in
            if !granted { return }
            let event = EKEvent(eventStore: store)
            event.title = self.eventTitle.text!
            let dateFormatter = DateFormatter()
            let dateString = self.startMonth.text! + "-" + self.startDay.text! + "-" + self.startYear.text! + " " + self.startTime.text!
            let endDateString = self.endMonth.text! + "-" + self.endDay.text! + "-" + self.endYear.text! + " " + self.endTime.text!
            
            dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        
            event.startDate = dateFormatter.date(from: dateString)!
            event.endDate = dateFormatter.date(from: endDateString)!
            
            event.calendar = store.defaultCalendarForNewEvents
            do {
                try store.save(event, span: .thisEvent)
            } catch let e as NSError {
                print("something bad happened")
                return
            }
            print("submitted!")
            self.RetakeAction()
        }
        

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
                
                
                self.containerView.isHidden = false
                
                
                let types: NSTextCheckingResult.CheckingType = .date
                let detector = try? NSDataDetector(types: types.rawValue)
                let matches = detector!.matches(in: result, options: .reportCompletion, range: NSMakeRange(0, result.characters.count))
                
                let myDate = matches.first
                print(myDate)
                
                for match in matches {
                    print(match)
                    let formatter1 = DateFormatter()
                    formatter1.dateFormat = "MM"
                    let formatter2 = DateFormatter()
                    formatter2.dateFormat = "dd"
                    let formatter3 = DateFormatter()
                    formatter3.dateFormat = "yyyy"
                    let formatter4 = DateFormatter()
                    formatter4.dateFormat = "HH:mm"
                    self.startMonth.text = formatter1.string(from: match.date! as Date)
                    self.startDay.text = formatter2.string(from: match.date! as Date)
                    self.startYear.text = formatter3.string(from: match.date! as Date)
                    self.startTime.text = formatter4.string(from: match.date! as Date)
                    self.endMonth.text = formatter1.string(from: match.date! as Date)
                    self.endDay.text = formatter2.string(from: match.date! as Date)
                    self.endYear.text = formatter3.string(from: match.date! as Date)
                    

                    
                    let store = EKEventStore()
                    store.requestAccess(to: .event) {(granted, error) in
                        if !granted { return }
                        let event = EKEvent(eventStore: store)
                        event.title = "Event Title"
                        event.startDate = match.date! //today
                        // event.endDate = event.startDate.dateByAddingTimeInterval(60*60) //1 hour long meeting
                        event.calendar = store.defaultCalendarForNewEvents
                        // do {
                            // try store.save(event, span: .thisEvent, commit: true)
                            // self.savedEventId = event.eventIdentifier //save event id to access this particular event later
                        // } catch {
                            // Display error to user
                        // }
                    }
                }
                


                
                
                
                
                // let location: NSTextCheckingResult.CheckingType = .address
                // let detector2 = try? NSDataDetector(types: location.rawValue)
                // let matches2 = detector2!.matches(in: result, options: .reportCompletion, range: NSMakeRange(0, result.characters.count))
                
                /*
                for match in matches2 {
                    print(match)
                    let range = match.range
                    print(range)
                    // var index1 = result.index(result.endIndex, offsetBy: match.len)
                    // var substring = result.substring(to: index1)
                }
                */
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
