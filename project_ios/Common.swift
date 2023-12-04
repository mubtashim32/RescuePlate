//
//  Common.swift
//  project_ios
//
//  Created by Md. Mubtashim Abrar Nihal on 03/09/1402 AP.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class Restaurant {
    var email: String
    var password: String
    var username: String
    var name: String
    var location: String
    
    init(email: String, password: String, username: String, name: String, location: String) {
        self.email = email
        self.password = password
        self.username = username
        self.name = name
        self.location = location
    }
    
    func toAnyObject() -> Any {
        return [
            "email": self.email,
            "password": self.password,
            "username": self.username,
            "name": self.name,
            "location": self.location
        ]
    }
}

class Food {
    var restaurantId: String
    var restaurantName: String
    var name: String
    var details: String
    var tableNo: Int
    var price: Int
    var discount: Int
    var imageURL: String?
    
    init(restaurantId: String, restaurantName: String, name: String, details: String, tableNo: Int, price: Int, discount: Int) {
        self.restaurantId = restaurantId
        self.restaurantName = restaurantName
        self.name = name
        self.details = details
        self.tableNo = tableNo
        self.price = price
        self.discount = discount
    }
    
    func toAnyObject() -> Any {
        return [
            "restaurantId": self.restaurantId,
            "restaurantName": self.restaurantName,
            "name": self.name,
            "details": self.details,
            "tableNo": self.tableNo,
            "price": self.price,
            "discount": self.discount
        ]
    }
}

class RestaurantEntity : Restaurant {
    var key: String
    
    init(key: String, email: String, password: String, username: String, name: String, location: String) {
        self.key = key
        super.init(email: email, password: password, username: username, name: name, location: location)
    }
}

class X: Codable {
    //var data: [String: Double]
    var success: Bool
    var timestamp: Int
    var base: String
    var date: String
    var rates: [String: Double]
}

var restaurantKey: String!
var myRestaurant: Restaurant!
var foodKey: String!
var selectedFoodKey: String!
var dollarRate: Double!

let reference = Database.database().reference()
let requestsRef = reference.child("requests")
let restaurantsRef = reference.child("restaurants")
let foodsRef = reference.child("foods")

func addToRequests(userID: String, restaurant: Restaurant) {
    requestsRef.child(userID).setValue(restaurant.toAnyObject())
}

func removeFromRequests(key: String) {
    requestsRef.child(key).removeValue()
}

func removeFromFoods(key: String) {
    foodsRef.child(key).removeValue()
}

func addToRestaurants(restaurant: RestaurantEntity) {
    restaurantsRef.childByAutoId().setValue(restaurant.toAnyObject())
}

func addFoodToRestaurant(food: Food) {
    foodsRef.child(foodKey).setValue(food.toAnyObject())
}

func xyz() {
    //let urlString = "https://api.freecurrencyapi.com/v1/latest?apikey=fca_live_IpnAS6kX5ieWZKg8RUGQyZAi1YgF3sbw8pjvRJuF"
    let urlString = "http://api.exchangeratesapi.io/v1/latest?access_key=72af372fa80706691a117de75a528c8d&format=1"
    let url = URL(string: urlString)
    guard url != nil else {
        return
    }
    let session = URLSession.shared
    let dataTask = session.dataTask(with: url!) { (data, response, error) in
        print(error)
        print(data)
        print(response)
        if error == nil && data != nil {
            let decoder = JSONDecoder()
            do {
                let x = try decoder.decode(X.self, from: data!)
                dollarRate = x.rates["BDT"]
                print(dollarRate)
            }
            catch {
                print("Error in JSON parsing")
            }
        }
    }
    dataTask.resume()
}
