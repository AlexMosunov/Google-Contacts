//
//  ViewController.swift
//  Google Contacts
//
//  Created by Alex Mosunov on 23.01.2021.
//
// Client ID - 525765886907-lc7t1n41djild1sskqtld77csd8aa262.apps.googleusercontent.com

import UIKit
import GoogleSignIn

class ViewController: UIViewController {
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    var signInButton: GIDSignInButton?
    var networkManager: NetworkManager?
    
    var receivedData: [String] = []
    var filteredData: [String] = []
    var filtered = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.delegate = self
        networkManager = (UIApplication.shared.delegate as! AppDelegate).networkManager
        networkManager?.delegate = self

        (UIApplication.shared.delegate as! AppDelegate).signInCallBack = refreshInterface
    
        GIDSignIn.sharedInstance()?.presentingViewController = self
        // Automatically sign in the user.
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()

        // Set signIn Button
        signInButton = GIDSignInButton(frame: CGRect(x: 0,y: 0,width: 100,height: 50))
        signInButton?.center = view.center
        if signInButton != nil {
            view.addSubview(signInButton!)
        }
        
        refreshInterface()

        
    }
    
    func refreshInterface() {
        if let currentUser = GIDSignIn.sharedInstance()?.currentUser {
            textField.isHidden = false
            tableView.isHidden = false
            signInButton?.isHidden = true
            signOutButton.isHidden = false
            welcomeLabel.text = "Welcome, \(currentUser.profile.name ?? "User")"
            let profilePicUrl = currentUser.profile.imageURL(withDimension: 175)
            DispatchQueue.global().async { [weak self] in
                if let url = profilePicUrl,let data = try? Data(contentsOf: url) {
                    if let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self?.profilePic.image = image
                        }
                    }
                }
            }
            profilePic.isHidden = false
        } else {
            textField.isHidden = true
            tableView.isHidden = true
            signInButton?.isHidden = false
            signOutButton.isHidden = true
            welcomeLabel.text = "Please Sign In"
            profilePic.image = nil
            profilePic.isHidden = true
        }
    }
    
    
    @IBAction func signOutButtonTapped(_ sender: UIButton) {
        GIDSignIn.sharedInstance()?.signOut()
        refreshInterface()
    }
}



//MARK: - Table View Delegate & DataSource

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !filteredData.isEmpty {
            return filteredData.count
        } else {
            return filtered ? 0 : receivedData.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell", for: indexPath) as! ContactTableViewCell
        if !filteredData.isEmpty {
            cell.textLabel?.text = filteredData[indexPath.row]
        } else {
            cell.textLabel?.text = receivedData[indexPath.row]
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        textField.resignFirstResponder()
    }
    
}


//MARK: - Network manager Delegate

extension ViewController: NetworkManagerDelegate {
    func didUpdateData(_ weatherManager: NetworkManager, data: [String]) {
        receivedData =  data
        print("received contacts DATATAA - \(data)")
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

//MARK: - Text Field Delegate

extension ViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text {
            if string.count == 0 {
                filterText(String(text.dropLast()))
            } else {
                filterText(text + string)
            }
        }
        return true
    }
    
    
    func filterText(_ query: String) {
        filteredData.removeAll()
        for string in receivedData {
            if string.lowercased().starts(with: query.lowercased()) {
                filteredData.append(string)
            }
        }
        tableView.reloadData()
        filtered = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
}
