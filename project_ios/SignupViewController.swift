//
//  SignupViewController.swift
//  project1520
//
//  Created by kuet on 5/11/23.
//
import FirebaseDatabase
import FirebaseAuth
import UIKit
class SignupViewController: UIViewController {
    @IBOutlet weak var resPass: UITextField!
    @IBOutlet weak var resUsername: UITextField!
    @IBOutlet weak var reEmail: UITextField!
    @IBOutlet weak var resLocation: UITextField!
    @IBOutlet weak var resName: UITextField!
    private let database = Database.database().reference()
    override func viewDidLoad() {
        super.viewDidLoad()
        resPass.isSecureTextEntry = true
    }
    @IBAction func goToLogin(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(identifier: "Login") as! ViewController
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    @IBAction func signupbutton(_ sender: Any) {
        let restaurant = Restaurant(email: reEmail.text!,
                                    password: resPass.text!,
                                    username: resUsername.text!,
                                    name: resName.text!,
                                    location: resLocation.text!)
        
        guard let email = reEmail.text, !email.isEmpty,
              let password = resPass.text, !password.isEmpty
        else {
            return
        }
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { [weak self] result, error in
            guard let strongSelf = self else {
                return
            }
            guard error == nil
            else {
                    return
            }
            let userID = Auth.auth().currentUser?.uid
            addToRequests(userID: userID!, restaurant: restaurant)
            let vc = self?.storyboard?.instantiateViewController(identifier: "Login") as! ViewController
            vc.modalPresentationStyle = .fullScreen
            self?.present(vc, animated: true)
        } )
    }
}
