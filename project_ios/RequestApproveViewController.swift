//
//  RequestApproveViewController.swift
//  project1520
//
//  Created by kuet on 12/11/23.
//
import Firebase
import UIKit

var requests: [RestaurantEntity] = []

class RequestApproveViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var requestTableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestsRef.observeSingleEvent(of: .value) { (snapshot)  in
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
                        print(restaurant)
                        requests.append(restaurant)
                        self.requestTableView.reloadData()
                    }

                          
                }
            }
        }
        requestTableView.delegate = self
        requestTableView.dataSource = self
        //requestTableView = UITableView.automaticDimension
        requestTableView.estimatedRowHeight = 127
        // Do any additional setup after loading the view.
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        //print("selected")
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let reject = UIContextualAction(style: .destructive, title: "Reject", handler: {(_, _, _) in
            self.requestTableView.beginUpdates()
            
            var request = requests[indexPath.row]
            
            removeFromRequests(key: request.key)
            
            requests.remove(at: indexPath.row)
            self.requestTableView.deleteRows(at: [indexPath], with: .fade)
            self.requestTableView.endUpdates()
        })
        let swipe = UISwipeActionsConfiguration(actions: [reject])
        return swipe
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let approve = UIContextualAction(style: .destructive, title: "Approve", handler: {(_, _, _) in
            self.requestTableView.beginUpdates()
            
            var request = requests[indexPath.row]
            
            removeFromRequests(key: request.key)
            addToRestaurants(restaurant: request)
            
            requests.remove(at: indexPath.row)
            self.requestTableView.deleteRows(at: [indexPath], with: .fade)
            self.requestTableView.endUpdates()
        })
        approve.backgroundColor = .green
        let swipe = UISwipeActionsConfiguration(actions: [approve])
        return swipe
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return requests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let request = requests[indexPath.row]
        let cell = requestTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        
        cell.resname!.text = request.name
        cell.reslocation!.text = request.location
        cell.resemail!.text = request.email
        print(cell.resname.text)
        return cell
    }

}
