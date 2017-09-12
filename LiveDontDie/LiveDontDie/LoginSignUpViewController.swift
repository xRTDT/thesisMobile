//
//  LoginSignUpViewController.swift
//  LiveDontDie
//
//  Created by Daniel Ham on 9/1/17.
//  Copyright © 2017 Timothy Yoon. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth


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
    
    func createAlert (title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in}))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func LoginButtonPressed(_ sender: Any) {
        FIRAuth.auth()?.signIn(withEmail: emailField.text!, password: passwordField.text!, completion: { (user, error) in
            if error != nil {
                self.createAlert(title: "Login Unsuccessful", message: "Please input correct email address and password.")
                print(error!)
            } else {
                print("success")
                self.performSegue(withIdentifier: "toAr", sender: self)
            }
        })
    }
    @IBAction func SignUpButtonPressed(_ sender: Any) {
        FIRAuth.auth()?.createUser(withEmail: emailField.text!, password: passwordField.text!, completion: { (user: FIRUser?, error) in
            if error != nil {
                self.createAlert(title: "Sign Up Unsuccessful", message: "Please input correct email address and password. Password must be at least 6 characters.")
                print(error!)
            } else {
                guard let uid = user?.uid else {
                    return
                }
                print("success")
                let userId = FIRDatabase.database().reference().child("Users").child(uid)
                let values = ["name": self.emailField.text!, "HighScore": 0] as [String : Any]
                userId.updateChildValues(values, withCompletionBlock: {(error, ref) in
                    if error != nil {
                        print(error!)
                    } else {
                        self.performSegue(withIdentifier: "toAr", sender: self)
                    }
                })
            }
        })
    }
    
    
//    @IBAction func SignupPressed(_ sender: AnyObject) {
//        FIRAuth.auth()?.createUser(withEmail: self.emailField.text!, password: self.passwordField.text!, completion: { (user, error) in
//            if error != nil {
//                print("signup unsuccessful")
//                print(error!)
//                let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
//                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//                alertController.addAction(defaultAction)
//                self.present(alertController, animated: true, completion: nil)
//            } else {
//                print("success")
//                self.performSegue(withIdentifier: "SignupToAr", sender: self)
////                let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignupToAr")
////                self.present(vc!, animated: true, completion: nil)
//                //SVProgressHUD.dismiss()
//            }
//        })
//    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
