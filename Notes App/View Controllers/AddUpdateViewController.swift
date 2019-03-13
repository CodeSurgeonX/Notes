//
//  AddUpdateViewController.swift
//  Notes App
//
//  Created by Shashwat  on 12/03/19.
//  Copyright © 2019 Shashwat . All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class AddUpdateViewController: UIViewController {
    
    var location = CLLocationManager()
    var locationRetrievalState : LocationState = .Fail
    var container : NSPersistentContainer?
    var state : AddUpdateViewControllerState?
    var model : Notes?
    var coordinates : (Double, Double) = (0,0)
    
    @IBOutlet weak var titleHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var descriptionHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleTextField: UITextView! {
        didSet {
            titleTextField.delegate = self
            titleTextField.isScrollEnabled = false
            titleTextField.layer.borderColor = UIColor.gray.cgColor
            titleTextField.layer.borderWidth = 1
            titleTextField.layer.cornerRadius = 5
        }
    }
    @IBOutlet weak var descriptionTextField: UITextView! {
        didSet {
            descriptionTextField.delegate = self
            descriptionTextField.isScrollEnabled = false
            descriptionTextField.layer.borderColor = UIColor.gray.cgColor
            descriptionTextField.layer.borderWidth = 1
            descriptionTextField.layer.cornerRadius = 5
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
        if state == .Add {
            setupLocationManager()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let currentState = self.state {
            if currentState == AddUpdateViewControllerState.Update, let currentModel = self.model {
                titleTextView.text = currentModel.title
                descriptionTextView.text = currentModel.desc
                let size = CGSize(width: 2*(view.frame.width/3), height: CGFloat.infinity)
                var estimateSize = titleTextView.sizeThatFits(size)
                titleHeightConstraint.constant = estimateSize.height
                estimateSize = descriptionTextView.sizeThatFits(size)
                descriptionHeightConstraint.constant = estimateSize.height
            }
        }
    }
    
    @objc func doneTapped(){
        if self.state == AddUpdateViewControllerState.Update {
            updateModel()
        }else if self.state == AddUpdateViewControllerState.Add {
            createNewNote()
        }
       navigationController?.popToRootViewController(animated: true)
    }
    
    func createNewNote(){
        
        if let title = titleTextView.text, let description = descriptionTextView.text, title.count > 0, let context = container?.viewContext {
            let stagedNotesModel = Notes(context: context)
            stagedNotesModel.title = title
            stagedNotesModel.desc = description
            stagedNotesModel.created = Date()
            if locationRetrievalState == .Success {
                stagedNotesModel.latitude = coordinates.0
                stagedNotesModel.longitude = coordinates.1
            }
            do {
                try context.save()
            }catch {
                print(error.localizedDescription)
            }
        }
        
    }
    
    func updateModel(){
        if let currentModel = model {
            if let title = titleTextView.text, let description = descriptionTextView.text, title.count > 0, let context = container?.viewContext {
                currentModel.title = title
                currentModel.desc = description
                do {
                    try context.save()
                }catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
}
extension AddUpdateViewController : UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        
        let size = CGSize(width: 2*(view.frame.width/3), height: CGFloat.infinity)
        let estimateSize = textView.sizeThatFits(size)
        
        if let id = textView.accessibilityIdentifier {
            if id == "Title"{
                titleHeightConstraint.constant = estimateSize.height
            }else{
                descriptionHeightConstraint.constant = estimateSize.height
            }
        }
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}


extension AddUpdateViewController : CLLocationManagerDelegate {
    func setupLocationManager(){
        location.delegate = self
        location.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        location.requestWhenInUseAuthorization()  //Requesting “Always” authorization is discouraged because of the potential negative impacts to user privacy. You should request this level of authorization only when doing so offers a genuine benefit to the user.
        location.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locus = locations[locations.count - 1]
        let latitude = locus.coordinate.latitude
        let longitude = locus.coordinate.longitude
        coordinates = (latitude, longitude)
        if locus.horizontalAccuracy > 0 {
            location.stopUpdatingLocation()                                        //Saves battery of the user
            locationRetrievalState = .Success
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationRetrievalState = .Fail
    }
}
