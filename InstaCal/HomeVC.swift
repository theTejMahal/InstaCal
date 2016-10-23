//
//  ViewController.swift
//  InstaCal
//
//  Created by Jet on 10/22/16.
//  Copyright © 2016 InstaCal. All rights reserved.
//

import UIKit
import LLSimpleCamera
import MediaPlayer
import AVFoundation

class HomeVC: UIViewController {
    
    @IBOutlet weak var cameraView: UIView!
    var camera = LLSimpleCamera()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        camera.start()
        
        // Use volume button to capture photo
        
        let volumeView = MPVolumeView(frame: CGRect(x: -CGFloat.greatestFiniteMagnitude, y: 0.0, width: 0.0, height: 0.0))
        self.view.addSubview(volumeView)
        NotificationCenter.default.addObserver(self, selector: #selector(volumeChanged(notification:)), name: NSNotification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        camera.stop()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification"), object: nil)
    }
    
    // Volume button listener (captures both volume buttons)
    func volumeChanged(notification: NSNotification) {
        if let userInfo = notification.userInfo,
            let volumeChangeType = userInfo["AVSystemController_AudioVolumeChangeReasonNotificationParameter"] as? String {
            if volumeChangeType == "ExplicitVolumeChange" {
                captureAction()
            }
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        print("im here")

    }
    
    @IBAction func captureAction() {
        print("hello")
        self.camera.capture({(camera, image, metadata, error) -> Void in
            
            // Delay stopping camera so that camera trigger sound does not get cut
            //DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            //    camera?.stop()
            //}
            
                
                // Display image preview
                if let vc = UIStoryboard(name: "ImagePreviewVC", bundle: nil).instantiateInitialViewController() as? ImagePreviewVC {
                    vc.capturedImage = image
                    self.present(vc, animated: false, completion: nil)
                }
            
            }, exactSeenImage: true)
    
        }

func setupCamera() {
    let screenRect = UIScreen.main.bounds;
    
    camera = LLSimpleCamera(quality: AVCaptureSessionPresetHigh, position: LLCameraPositionRear, videoEnabled: true)
    let vc = UIViewController()
    vc.view.frame = cameraView.bounds
    
    camera.attach(to: vc, withFrame: CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height))
    cameraView.addSubview(vc.view)
    camera.fixOrientationAfterCapture = true;
    
    self.camera.onError = { (camera, error) -> Void in
        print(error)
        
    }
}
}

