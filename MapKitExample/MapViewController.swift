//
//  MapViewController.swift
//  MapKitExample
//
//  Created by Michael Budd on 7/16/18.
//  Copyright © 2018 Michael Budd. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Properties
    
    var monuments: [Monument] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                for monument in self.monuments {
                    self.mapView.addAnnotation(monument)
                }
            }
        }
    }
    
    let apiEndpoint = "https://true-donair-12437.herokuapp.com/seven_wonders"
    var routePolyline: MKPolyline?
    
    // MARK: - Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpMap()
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.mapLongPress(_:))) // colon needs to pass through info
        longPress.minimumPressDuration = 1.0 // in seconds
        //add gesture recognition
        mapView.addGestureRecognizer(longPress)
    }
    
    func setUpMap() {
        
        mapView.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.clear
        displayCurrentLocation()
        
        NetworkController.shared.fetchMonuments(from: apiEndpoint.asUrl()) { monuments in
            guard
                let monuments = monuments
                else {
                    return
            }
            self.monuments = monuments
        }
        
    }

    // MARK: - TableView Delegate Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return monuments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "monumentCell", for: indexPath)
        let monument = monuments[indexPath.row]
        
        cell.textLabel?.text = monument.name
        cell.backgroundColor = UIColor.clear
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let monument = monuments[indexPath.row]
        updateRegion(showing: monument)
        
    }
    
    // MARK: - MapView Delegate Methods
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        // Checking to see what kind of annotation we are trying to load. This check can be helpful if you have different types of annotaions that require different set up such as images or colors.
        if annotation is Monument {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "Marker") as? MKMarkerAnnotationView
            
            if let dequedAnnotationView = annotationView {
                dequedAnnotationView.annotation = annotation
            } else {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "Marker")
            }
            
            // Creates the call out accessory as a default 'info button' provided by MapKit.
            let callOutButton = UIButton(type:.infoDark) as UIButton
            
            // Allows the annotation to display a 'callout' or secondary view on the annotation. This is where the 'calloutAccessory'/info button will be displayed when an annotation is tapped on.
            annotationView?.canShowCallout = true
            annotationView?.rightCalloutAccessoryView = callOutButton
            annotationView?.glyphImage = UIImage(named: "Monument")
            annotationView?.titleVisibility = .visible
            
            return annotationView
        }
        return nil
    }
    
    func displayCurrentLocation() {
        
        // If location permisions not yet granted, will display an alert requesting location permisions when the app is in use.
        LocationManager.shared.askForLocationPermissions()
        
        // Once location permissions are granted, we display their current location on the mapview and update the region to zoom in on that point.
        if CLLocationManager.locationServicesEnabled() {
            mapView.showsUserLocation = true
            updateRegion(showing: nil)
        }
    }
    
    func updateRegion(showing: Monument?) {
        if showing == nil {
            
            // If no monument was passed in, we use to the user's current location
            guard
                let currentLocation = LocationManager.shared.currentLocation
                else {
                    return
            }
            
            // Creating a region for the mapview to display as the center and animating the scroll to that region.
            let region = MKCoordinateRegion(center: currentLocation, span: MKCoordinateSpan(latitudeDelta: 7, longitudeDelta: 7))
            mapView.region = region
            
        } else if showing != nil {
            
            // If a monument was passed in, we call 'setCenter' on that monument. The setCenter method is a method provided by MapKit that creates a region and animates (or doesn't) the scrolling to that region the same way we did on our own in the cae of showing == nil.
            mapView.setCenter((showing?.coordinate)!, animated: true)
        }
    }
    
    // MARK: - Extras
    
    @objc func mapLongPress(_ recognizer: UIGestureRecognizer) {
        
        print("A long press has been detected.")
        
        // Stores the location tapped from the gesture recognizer and converts it into a CLLocationCoordinate2D.
        let touchedAt = recognizer.location(in: self.mapView)
        let touchedAtCoordinate : CLLocationCoordinate2D = mapView.convert(touchedAt, toCoordinateFrom: self.mapView)
        
        // Creates a new monument using the CLLocationCoordinate2D created in the previous step and appends it to the monuments array. The didSet on monuments updates the mapview with the annotation.
        let newMonument = Monument(name: "New Monument", latitude: touchedAtCoordinate.latitude, longitude: touchedAtCoordinate.longitude)
        self.monuments.append(newMonument)
        
    }
    
    
    
    
}
