//
//  ViewController.swift
//  FaceFinder
//
//  Created by Molnár Csaba on 2019. 09. 08..
//  Copyright © 2019. Molnár Csaba. All rights reserved.
//

import UIKit
import Vision

class ViewController: UIViewController {
    
    @IBOutlet weak var spiner: UIActivityIndicatorView!
    @IBOutlet weak var msgLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spiner.hidesWhenStopped = true
        setupImageView()
    }

    func setupImageView(){
        guard let image = UIImage(named: "friends" ) else { return }
        
        guard let cgimage = image.cgImage else {
            print("could not find CGImage")
            return
        }
        
        let scaledHeight = (view.frame.width / image.size.width) * image.size.height
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: scaledHeight)
        
        view.addSubview(imageView)
        
        spiner.startAnimating()
        
        DispatchQueue.global(qos: .background).async {
            self.perfomrVisionRequest(for: cgimage, with: scaledHeight)
        }
    }
    
    func createFaceOutline(for rectangle: CGRect) {
        let yellowView = UIView()
        yellowView.backgroundColor = .clear
        yellowView.layer.borderColor = UIColor.yellow.cgColor
        yellowView.layer.borderWidth = 3
        yellowView.layer.cornerRadius = 5
        yellowView.alpha = 0.0
        yellowView.frame = rectangle
        self.view.addSubview(yellowView)
        
        UIView.animate(withDuration: 0.3){
            yellowView.alpha = 0.75
            self.spiner.alpha = 0.0
            self.msgLabel.alpha = 0.0
        }
        
        self.spiner.stopAnimating()
    }

    func perfomrVisionRequest(for image: CGImage, with scalledheight: CGFloat) {
        let faceDetectionRequest = VNDetectFaceRectanglesRequest { (request, error) in
            if let error = error {
                print("failed to detect face: ", error)
                return
            }
            request.results?.forEach({ (result) in
                guard let faceObservation = result as? VNFaceObservation else { return }
                
                DispatchQueue.main.async {
                    let width = self.view.frame.width * faceObservation.boundingBox.width
                    let height = scalledheight * faceObservation.boundingBox.height
                    let faceX = self.view.frame.width * faceObservation.boundingBox.origin.x
                    let facey = scalledheight * (1 - faceObservation.boundingBox.origin.y) - height
                    
                    
                    let facerect = CGRect(x: faceX, y: facey, width: width, height: height)
                    self.createFaceOutline(for: facerect)
                }
            })
        }
        
        let imageRequestHandler = VNImageRequestHandler(cgImage: image, options: [:])
        
        do {
            try imageRequestHandler.perform([faceDetectionRequest])

        } catch {
            print("failed to perform imagerequest", error.localizedDescription)
            return
        }
        
        
    }

}

