//
//  NetworkManager.swift
//  Google Contacts
//
//  Created by Alex Mosunov on 23.01.2021.
//

import Foundation

protocol NetworkManagerDelegate {
    func didUpdateData(_ weatherManager: NetworkManager, data: [String])
    //    func didFailWithError(error: Error)
}

class NetworkManager {
    
    var delegate: NetworkManagerDelegate?
    
    func getUserContacts(token : String){
        let urlString = "https://www.google.com/m8/feeds/contacts/default/full?access_token=\(token)&max-results=\(999)&alt=json&v=3.0"
        
        print(urlString)
        
        let url = URL(string: urlString)
        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "GET"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        session.dataTask(with: url!, completionHandler: { data, response, error in
            if(error != nil) {
                print("Error 2 :\(error!)")
            }
            
            if let safeData = data {
                if let contacts = self.parseJSON(safeData) {
                    self.delegate?.didUpdateData(self, data: contacts)
                }
            }
        }).resume()
        
    }
    
    
    func parseJSON(_ contactsData: Data) -> [String]? {
        let decoder = JSONDecoder()
        var contacts: [String] = []
        do {
            let decodedData = try decoder.decode(ContactData.self, from: contactsData)
            
            for entry in decodedData.feed.entry {
                if let name = entry.title?.contactTitle, !name.isEmpty {
                    contacts.append(name)
                }
            }
            return contacts
            
        } catch let error as NSError {
            print("Error 3 :\(error)")
            return nil
        }
    }
    
    
}
