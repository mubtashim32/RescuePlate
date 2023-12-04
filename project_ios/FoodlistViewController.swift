//
//  FoodlistViewController.swift
//  project_ios
//
//  Created by Md. Mubtashim Abrar Nihal on 02/09/1402 AP.
//

import UIKit
import FirebaseStorage

class FoodlistViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var foodList: UITableView!
    @IBOutlet weak var addFood: UIButton!
    
    var foods: [Food] = []
    var keys: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addFood.addTarget(self, action: #selector(addFoodToRestaurant), for: .touchUpInside)
                
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
                        if food.restaurantId == restaurantKey {
                            self.foods.append(food)
                            self.keys.append(key)
                            self.foodList.reloadData()
                        }
                        
                    }
                }
            }
        }
        foodList.delegate = self
        foodList.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let reject = UIContextualAction(style: .destructive, title: "Reject", handler: {(_, _, _) in
            self.foodList.beginUpdates()
            
            var food = self.foods[indexPath.row]
            var key = self.keys[indexPath.row]
            
            removeFromFoods(key: key)
            
            self.foods.remove(at: indexPath.row)
            self.keys.remove(at: indexPath.row)
            self.foodList.deleteRows(at: [indexPath], with: .fade)
            self.foodList.endUpdates()
        })
        let swipe = UISwipeActionsConfiguration(actions: [reject])
        return swipe
    }
    
    @objc func addFoodToRestaurant() {
        let foodList_insertFood = self.storyboard?.instantiateViewController(identifier: "AddFood") as! AddFoodViewController
        self.present(foodList_insertFood, animated: true)
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
        let cell = foodList.dequeueReusableCell(withIdentifier: "feedCard", for: indexPath) as! FeedCard
        
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
        cell.restaurantName.text = myRestaurant.name
        return cell
    }
    
}
