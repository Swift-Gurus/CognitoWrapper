//
//  ViewController.swift
//  CognitoWrapper
//
//  Created by egarro@aldogroup.com on 12/10/2018.
//  Copyright (c) 2018 egarro@aldogroup.com. All rights reserved.
//

import UIKit
import CognitoWrapper
import EitherResult


final class CredentialsProvider : CognitoUserCredentialsProvider {
    var username: String = ""
    var password: String = ""
}

final class PoolDetailsProvider : CognitoUserPoolProvider {
    let clientID: String = "[REPLACE WITH YOUR AWS CLIENT ID]"
    let poolID: String = "[REPLACE WITH YOUR AWS POOL ID]"
}

struct Info : Decodable {
    var given_name: String
    var family_name: String
    var userName: String
}

class ViewController: UIViewController {
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    private var poolDetailsProvider = PoolDetailsProvider()
    private var credentialsProvider = CredentialsProvider()
    private var authorizer : CognitoWrapper!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        authorizer = CognitoWrapper(userPool: poolDetailsProvider)
        errorLabel.text =  ""
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "loginSegue") {
            if let x = sender as? LoginResponse<Info> {
                (segue.destination as! NextController).data = Info(given_name: x.data.given_name,
                                                                   family_name: x.data.family_name,
                                                                   userName: x.data.userName)
                (segue.destination as! NextController).token = x.authToken
            }
        }
    }

    private func processResponse(result: ALResult<LoginResponse<Info>>) -> Void {
        result.map({ [weak self] (response) in
                    DispatchQueue.main.async {
                        self?.performSegue(withIdentifier: "loginSegue", sender: response)
                    }
               }).onError({ (error) in
                    DispatchQueue.main.async {
                        self.errorLabel.text = "Cannot log in this user! \(error)"
                    }
               })
    }
    
    @IBAction func pressLogin(_ sender: Any) {
        errorLabel.text =  ""
        credentialsProvider.username = self.usernameField.text!
        credentialsProvider.password = self.passwordField.text!
        
        authorizer.login(with: credentialsProvider, completion: processResponse)
    }
}

