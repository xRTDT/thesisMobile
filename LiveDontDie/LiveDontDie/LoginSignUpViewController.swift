//
//  LoginSignUpViewController.swift
//  LiveDontDie
//
//  Created by Daniel Ham on 9/1/17.
//  Copyright © 2017 Timothy Yoon. All rights reserved.
//

import UIKit
import Firebase

class LoginSignUpViewController: UIViewController {
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func LoginPressed(_ sender: Any) {
        FIRAuth.auth()?.signIn(withEmail: emailField.text!, password: passwordField.text!, completion: { (user, error) in
            if error != nil {
                print(error!)
            } else {
                print("signin successful")
                //SVProgressHUD.dismiss()
                self.performSegue(withIdentifier: "LoginToAr", sender: self)
            }
        })
    }
    @IBAction func SignupPressed(_ sender: Any) {
        FIRAuth.auth()?.createUser(withEmail: emailField.text!, password: passwordField.text!, completion: { (user, error) in
            if error != nil {
                print(error!)
            } else {
                print("signup successful")
                //SVProgressHUD.dismiss()
                self.performSegue(withIdentifier: "SignupToAr", sender: self)
            }
        })
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
