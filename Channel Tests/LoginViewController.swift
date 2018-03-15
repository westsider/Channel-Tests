//
//  LoginViewController.swift
//  Channel Tests
//
//  Created by Warren Hansen on 3/15/18.
//  Copyright © 2018 Warren Hansen. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var siChart: UITextField!
    
    @IBOutlet weak var alpha: UITextField!
    
    @IBOutlet weak var firebaseLogin: UITextField!
    
    @IBOutlet weak var firebasePass: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func loginAction(_ sender: Any) {
        saveLogins()
    }
    
    func saveLogins() {
        
        if  let alphaApi = alpha.text  {
            if alphaApi.count < 8 {
                alpha.text = "more characters required"
                return
            }
            UserDefaults.standard.set(alphaApi, forKey: "alphaApiKey")
        } else {
            print("No Alpha API Set")
        }
        
        if  let firebaseUser = firebaseLogin.text  {
            if firebaseUser.count < 8 {
                firebaseLogin.text = "more characters required"
                return
            }
            UserDefaults.standard.set(firebaseUser, forKey: "userFireBase")
        } else {
            print("No Firebase User Set")
        }
        
        if  let firePass = firebasePass.text  {
            if firePass.count < 8 {
                firebasePass.text = "more characters required"
                return
            }
            UserDefaults.standard.set(firePass, forKey: "passwordFireBase")
        } else {
            print("No Firebase Pass Set")
        }
        
        if  let sciPassWord = siChart.text  {
            if sciPassWord.count < 8 {
                siChart.text = "more characters required"
                return
            }
            UserDefaults.standard.set(sciPassWord, forKey: "scichartLicense")
            segueToMainVC()
        } else {
            print("No Sci API Key Set")
        }
    }
    
    private func segueToMainVC() {
        navigationController?.popToRootViewController(animated: true)
    }

}
