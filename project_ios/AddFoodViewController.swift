//
//  AddFoodViewController.swift
//  project_ios
//
//  Created by Md. Mubtashim Abrar Nihal on 03/09/1402 AP.
//

import UIKit
import FirebaseStorage
import Firebase
import Photos
import SDWebImage


class AddFoodViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var details: UITextField!
    @IBOutlet weak var tableNo: UITextField!
    @IBOutlet weak var price: UITextField!
    @IBOutlet weak var discount: UITextField!
    @IBOutlet weak var add: UIButton!
    
    @IBOutlet weak var imageDownloaded: UIImageView!
    var imagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePickerController.delegate = self
        
        checkPermission()
        
        add.addTarget(self, action: #selector(addFood), for: .touchUpInside)
    }
    
    @IBAction func uploadImageTapped(_ sender: Any) {
        self.imagePickerController.sourceType = .photoLibrary
        self.present(self.imagePickerController, animated: true, completion: nil)
    }
    
    func checkPermission(){
        if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized {
            PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) -> Void in
                ()
            })
        }
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            
        } else {
            
        }
    }
    
    func requestAuthorizationHandler(status: PHAuthorizationStatus) {
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            print("access")
        } else {
            print("access false")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let url = info[UIImagePickerController.InfoKey.imageURL] as? URL {
            print(url)
            uploadToCloud(fileURL: url)
            
        }
        imagePickerController.dismiss(animated: true, completion: nil)
    }
    
    func pullImageTapped() {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        let ref = storageRef.child(foodKey)
        ref.downloadURL { (url, error) in
                if let error = error {
                    print("Error getting download URL: \(error.localizedDescription)")
                    return
                }
                if let downloadURL = url {
                    self.imageDownloaded.sd_setImage(with: downloadURL, completed: { (image, error, cacheType, imageURL) in
                        if let error = error {
                            print("Error setting image: \(error.localizedDescription)")
                        }
                    })
                }
            }
    }
    
    func uploadToCloud(fileURL: URL) {
        let storage = Storage.storage()
        let data = Data()
        let storageRef = storage.reference()
        let localFile = fileURL
        foodKey = foodsRef.childByAutoId().key
        let photoRef = storageRef.child(foodKey)
        let uploadTask = photoRef.putFile(from: localFile, metadata: nil) { (metadata, err) in
            guard let metadata = metadata else {
                print(err?.localizedDescription)
                return
            }
            print("upload")
            self.pullImageTapped()
        }
    }
    
    @objc func addFood() {
        var nameStr = name.text!
        var detailsStr = details.text!
        var tableNoStr = tableNo.text!
        var priceStr = price.text!
        var discountStr = discount.text!

        var tableNoInt = Int(tableNoStr)
        var priceInt = Int(priceStr)
        var discountInt = Int(discountStr)

        var food = Food(restaurantId: restaurantKey,
                        restaurantName: myRestaurant.name,
                        name: nameStr,
                        details: detailsStr,
                        tableNo: tableNoInt!,
                        price: priceInt!,
                        discount: discountInt!)
        print(food.discount)
        addFoodToRestaurant(food: food)
        let vc = self.storyboard!.instantiateViewController(identifier: "FoodListView") as! FoodlistViewController
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }

    

}




func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    print(3)
    if let selectedImage = info[.originalImage] as? UIImage {
        print(4)
        // Convert the UIImage to Data
        if let imageData = selectedImage.jpegData(compressionQuality: 0.8) {
            // Now you can use imageData in your Firebase Storage upload task
            print(5)
            uploadImageToFirebaseStorage(imageData: imageData)
        }
    }

    picker.dismiss(animated: true, completion: nil)
}

func uploadImageToFirebaseStorage(imageData: Data) {
    let storageRef = Storage.storage().reference()
    let imageRef = storageRef.child("images/your-image.jpg")

    let uploadTask = imageRef.putData(imageData, metadata: nil) { (metadata, error) in
        guard let metadata = metadata else {
            // Handle error
            return
        }
        imageRef.downloadURL { (url, error) in
            guard let downloadURL = url else {
                // Handle error
                return
            }
            // Use downloadURL to store in Firebase Realtime Database or perform any other action
            print("Image URL: \(downloadURL)")
            
        }
    }
}

        


