//
//  NetworkController.swift
//  MapKitExample
//
//  Created by Michael Budd on 7/16/18.
//  Copyright © 2018 Michael Budd. All rights reserved.
//

import Foundation

class NetworkController {
    
    static let shared = NetworkController()
    
    func fetchMonuments(from: URL, completion: @escaping ([Monument]?) -> () ) {
        
        URLSession.shared.dataTask(with: from) { (data, _, _) in
            
            if let data = data {
                do {
                    let json = try? JSONSerialization.jsonObject(with: data, options: [])
                    let arr = json as? [[String: Any]]
                    let obj = arr?.compactMap{ Monument($0) }
                    
                    completion(obj)
                }
            }
            completion(nil)
        }.resume()
        
    }
    
}

extension String {
    func asUrl() -> URL {
        return URL(string: self)!
    }
}

