//
//  ViewController.swift
//  project1520
//
//  Created by kuet on 5/11/23.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
class ViewController: UIViewController {
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        password.isSecureTextEntry = true
    }

    @IBAction func loginbutton(_ sender: Any) {
        
        guard let email = username.text, !email.isEmpty,
              let password = password.text, !password.isEmpty
        else {
            return
        }
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] result, error in
            guard let strongSelf = self else {
                return
            }
            guard error == nil
            else {
                    return
            }
            if email == "admin@gmail.com" {
                let vc = self!.storyboard!.instantiateViewController(identifier: "RequestApprove") as! RequestApproveViewController
                vc.modalPresentationStyle = .fullScreen
                self!.present(vc, animated: true)
            } else {
                
                restaurantsRef.observeSingleEvent(of: .value) { (snapshot)  in
                    if let requestsData = snapshot.value as? [String: [String: Any]]{
                        for(key, value) in requestsData {
                            if let email = value["email"] as? String,
                               let password = value["password"] as? String,
                               let username = value["username"] as? String,
                               let name = value["name"] as? String,
                               let location = value["location"] as? String {
                                let restaurant = RestaurantEntity(key: key,
                                                                  email: email,
                                                                  password: password,
                                                                  username: username,
                                                                  name: name,
                                                                  location: location)
                                if (self?.username.text! == email) {
                                    restaurantKey = key
                                    myRestaurant = restaurant
                                    let vc = self!.storyboard!.instantiateViewController(identifier: "FoodListView") as! FoodlistViewController
                                    vc.modalPresentationStyle = .fullScreen
                                    self!.present(vc, animated: true)
                                }
                            }
                        }
                    }
                }
            }
        } )

    }
    @IBAction func goToSignUp(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(identifier: "Signup") as! SignupViewController
        present(vc, animated: true)
    }
    
}

