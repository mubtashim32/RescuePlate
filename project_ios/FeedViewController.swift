//
//  FeedViewController.swift
//  project_ios
//
//  Created by Md. Mubtashim Abrar Nihal on 02/09/1402 AP.
//

import UIKit
import FirebaseStorage

var foods: [Food] = []
var keys: [String] = []
var resNames: [String] = []

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var foodsTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        xyz()
        foodsRef.observeSingleEvent(of: .value) { (snapshot)  in
            if let requestsData = snapshot.value as? [String: [String: Any]]{
                for(key, value) in requestsData {
                    if let restaurantId = value["restaurantId"] as? String,
                       let restaurantName = value["restaurantName"] as? String,
                       let name = value["name"] as? String,
                       let details = value["details"] as? String,
                       let tableNo = value["tableNo"] as? Int,
                       let price = value["price"] as? Int,
                       let discount = value["discount"] as? Int {
                        let food = Food(restaurantId: restaurantId,
                                        restaurantName: restaurantName,
                                        name: name,
                                        details: details,
                                        tableNo: tableNo,
                                        price: price,
                                        discount: discount)
                        food.imageURL = key
                        print(food.toAnyObject())
                        foods.append(food)
                        keys.append(key)
                        self.foodsTable.reloadData()
                    }
                }
            }
        }
        foodsTable.delegate = self
        foodsTable.dataSource = self
    }
    
    @IBAction func goToLogin(_ sender: Any) {
        print("Hey")
        let vc = self.storyboard?.instantiateViewController(identifier: "Login") as! ViewController
        self.present(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        print(indexPath.row)
        selectedFoodKey = keys[indexPath.row]
        let vc = self.storyboard?.instantiateViewController(identifier: "Details") as! DetailedViewController
        self.present(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foods.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let food = foods[indexPath.row]
        let cell = foodsTable.dequeueReusableCell(withIdentifier: "feedCard", for: indexPath) as! FeedCard
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        let ref = storageRef.child(food.imageURL!)
        ref.downloadURL { (url, error) in
                if let error = error {
                    print("Error getting download URL: \(error.localizedDescription)")
                    return
                }
                if let downloadURL = url {
                    cell.foodImage.sd_setImage(with: downloadURL, completed: { (image, error, cacheType, imageURL) in
                        if let error = error {
                            print("Error setting image: \(error.localizedDescription)")
                        }
                    })
                }
            }
        cell.foodName.text = food.name
        cell.price.text = "BDT: " + String(food.price)
        cell.discount.text = "-" + String(food.discount)
        cell.restaurantName.text = food.restaurantName
        
        return cell
    }

}
