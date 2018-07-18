//
//  Monument.swift
//  MapKitExample
//
//  Created by Michael Budd on 7/16/18.
//  Copyright © 2018 Michael Budd. All rights reserved.
//

import Foundation
import MapKit

class Monument: NSObject, MKAnnotation {
    
    var name: String
    var latitude: Double
    var longitude: Double
    
    init(name: String, latitude: Double, longitude: Double) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
    
    convenience init?(_ dict: [String: Any]) {
        guard
            let name = dict["name"] as? String,
            let lat = dict["latitude"] as? String,
            let latitude = Double(lat),
            let long = dict["longitude"] as? String,
            let longitude = Double(long)
            else {
                return nil
        }
        
        self.init(name: name, latitude: latitude, longitude: longitude)
    }
    
    public var title: String? {
        get { return name }
    }
    
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    
}





