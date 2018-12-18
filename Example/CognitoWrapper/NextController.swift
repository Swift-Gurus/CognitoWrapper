//
//  NextController.swift
//  CognitoWrapper_Example
//
//  Created by Esteban Garro on 2018-12-11.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

class NextController: UIViewController {
    
    @IBOutlet weak var resultLabel: UILabel!
    
    var data : Info? = nil
    var token: String = ""
    
    override func viewDidLoad() {
        if let d = data {
            resultLabel.text = "Hello \(d.given_name) \(d.family_name)!\nYour username is: \(d.userName)\nYou are now logged in!"
        }
        print("Auth token: \(token)")
    }
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}


