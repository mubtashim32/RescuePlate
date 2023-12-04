//
//  DetailedViewController.swift
//  project_ios
//
//  Created by Md. Mubtashim Abrar Nihal on 02/09/1402 AP.
//

import UIKit
import FirebaseStorage

class DetailedViewController: UIViewController {

    @IBOutlet weak var currencyConverter: UIButton!
    @IBOutlet weak var resName: UILabel!
    @IBOutlet weak var resLoc: UILabel!
    @IBOutlet weak var noOfTables: UILabel!
    @IBOutlet weak var foodDiscount: UILabel!
    @IBOutlet weak var foodPrice: UILabel!
    @IBOutlet weak var foodDescription: UILabel!
    @IBOutlet weak var foodName: UILabel!
    @IBOutlet weak var foodImage: UIImageView!
    
    var BDT: Double = 0.0
    var USD: Double = 0.0
    var BDTx: Double = 0.0
    var USDx: Double = 0.0
    var curBDT: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currencyConverter.backgroundColor = .cyan
        foodsRef.child(selectedFoodKey).observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                return
            }
            if let restaurantId = value["restaurantId"] as? String,
               let restaurantName = value["restaurantName"] as? String,
               let name = value["name"] as? String,
               let details = value["details"] as? String,
               let tableNo = value["tableNo"] as? Int,
               let price = value["price"] as? Int,
               let discount = value["discount"] as? Int {
                var food = Food(restaurantId: restaurantId,
                                restaurantName: restaurantName,
                                name: name,
                                details: details,
                                tableNo: tableNo,
                                price: price,
                                discount: discount)
                
                self.BDT = Double(food.price)
                self.USD = self.BDT / dollarRate
                
                self.BDTx = Double(food.discount)
                self.USDx = self.BDTx / dollarRate
                
                let storage = Storage.storage()
                let storageRef = storage.reference()
                
                let ref = storageRef.child(selectedFoodKey!)
                ref.downloadURL { (url, error) in
                        if let error = error {
                            print("Error getting download URL: \(error.localizedDescription)")
                            return
                        }
                        if let downloadURL = url {
                            self.foodImage.sd_setImage(with: downloadURL, completed: { (image, error, cacheType, imageURL) in
                                if let error = error {
                                    print("Error setting image: \(error.localizedDescription)")
                                }
                            })
                        }
                    }
                self.foodDescription.text = food.details
                self.foodName.textAlignment = .center
                self.foodName.text = food.name
                self.foodName.textAlignment = .center
                self.foodPrice.text = String(food.price)
                self.foodPrice.numberOfLines = 0
                self.foodDiscount.numberOfLines = 0
                self.foodDiscount.text = String(food.discount)
                
                restaurantsRef.child(food.restaurantId).observeSingleEvent(of: .value) { (snapshot)  in
                    if let requestsData = snapshot.value as? [String: Any] {
                        let value = requestsData
                        print(snapshot.key)
                        if let email = value["email"] as? String,
                           let password = value["password"] as? String,
                           let username = value["username"] as? String,
                           let name = value["name"] as? String,
                           let location = value["location"] as? String {
                            var restaurant = RestaurantEntity(key: snapshot.key,
                                                              email: email,
                                                              password: password,
                                                              username: username,
                                                              name: name,
                                                              location: location)
                            print(restaurant.toAnyObject())
                            self.resName.text = restaurant.name
                            self.resLoc.text = restaurant.location
                        }
                    }
                }
            }
        })
    }
    
    @IBAction func changeCurrency(_ sender: Any) {
        print(USD)
        print(USDx)
        if curBDT {
            foodPrice.text = String(format: "%.1f", USD)
            foodDiscount.text = String(format: "%.1f", USDx)
            currencyConverter.setTitle("Currency: USD", for: .normal)
        }
        else {
            foodPrice.text = String(format: "%.0f", BDT)
            foodDiscount.text = String(format: "%.0f", BDTx)
            currencyConverter.setTitle("Currency: BDT", for: .normal)
        }
        curBDT = !curBDT
    }
    
}
