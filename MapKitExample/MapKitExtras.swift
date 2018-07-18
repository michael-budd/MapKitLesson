//
//  MapKitExtras.swift
//  MapKitExample
//
//  Created by Michael Budd on 7/18/18.
//  Copyright © 2018 Michael Budd. All rights reserved.
//

import Foundation
import MapKit

extension MapViewController {
    
    /*
     This extension is an example of some extra methods that can be used with MapKit that I did not include in the lecture. I encourage anyone interested in learning more about MapKit to implement all of the examples in this project on their own, in a practice project. Doing this will help you understand not only what they do, but how they do it. You can showcase that project on your GitHub for potential employers.
    */
    
    /**  This method will allow you to pass in an MKAnnotaion and display a polyroute with the best drivable route from your current location. */
    func getDrivingDirectionsFromCurrentLocation(to: MKAnnotation?) {
        
        guard
            let destination = to
            else {
                return
        }
        
        // Creating a request with source and destination
        let drivingRouteRequest = MKDirectionsRequest()
        drivingRouteRequest.transportType = .automobile
        drivingRouteRequest.source = MKMapItem(placemark: MKPlacemark(coordinate: mapView.userLocation.coordinate))
        drivingRouteRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination.coordinate))
        
        // Using the request to generate directions
        let drivingRouteDirections = MKDirections(request: drivingRouteRequest)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        /*
        [unowned self] is a way to keep a weak reference to the polyline and prevent memory leaks. If you'd like to learn more about why I'm doing this here, you can start with this article:
        https://blog.haloneuro.com/swift-memory-leak-gotcha-with-weak-self-67293d5bc060
        */
        
        drivingRouteDirections.calculate { [unowned self] (response: MKDirectionsResponse?, error: Error?) in
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            
            // Making sure there is atleast one route
            guard let response = response else {
                print("\(String(describing: error?.localizedDescription))")
                return
            }
            
            // Selecting the first route
            guard let firstRoute = response.routes.first else {
                print("No Routes")
                return
            }
            
            // Removing any polyline that may have been set previously
            if let routePolyline = self.routePolyline {
                self.mapView.remove(routePolyline)
            }
            
            // Setting polyline as the route found in the response
            self.routePolyline = firstRoute.polyline
            
            // Presenting the polyline on the view
            DispatchQueue.main.async {
                self.mapView.add(firstRoute.polyline)
            }
        }
    }
    
    /**  This is a delegate method that allows the MapView to render paths such as an MKPolygon or MKPolyline in the view. */
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolygon {
            let render = MKPolygonRenderer(overlay: overlay)
            render.lineWidth = 1.5
            render.strokeColor = .green
            return render
        } else if overlay is MKPolyline {
            let render = MKPolylineRenderer(overlay: overlay)
            render.lineWidth = 2.0
            render.strokeColor = .blue
            return render
        } else {
            return MKOverlayRenderer()
        }
    }
    
    /**  A delegate method that allows the callout accessory to perform an action. In this case, it is calling the getDrivingDirections on the annotation. */
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // getDrivingDirectionsFromCurrentLocation(to: view.annotation)
        requestDirections(to: view.annotation!)
        
    }
    
    /** Creates a request for the system to open maps and display driving directions. This makes for a berrter UX than the polyroute. */
    func requestDirections(to: MKAnnotation) {
        
        let directionsUrl = URL(string: "http://maps.apple.com/?daddr=\(to.coordinate.latitude),\(to.coordinate.longitude)")!
        
        UIApplication.shared.open(directionsUrl, completionHandler: nil)
        
    }
    
    /** Call this function in the viewdidload to see how the mapview uses these coordinates to display a border around Utah. */
    func addUtahPolygon() {
        
        /***********************************************
         
         0 -------- 1            0 - UT, ID, NV
         |          |            1 - UT, ID, WY
         |          |            2 - UT, WY
         |          2 ----- 3    3 - UT, WY, CO
         |                  |    4 - UT, CO, AZ, NM
         |                  |    5 - UT, NV, AZ
         |                  |
         |                  |
         |                  |
         |                  |
         |                  |
         |                  |
         5 ---------------- 4
         
         **********************************************/
        let coordinates: [CLLocationCoordinate2D] = [CLLocationCoordinate2D(latitude: 41.99386, longitude: -114.04147),
                                                   CLLocationCoordinate2D(latitude: 42.00162, longitude: -111.04675),
                                                   CLLocationCoordinate2D(latitude: 40.99808, longitude: -111.04696),
                                                   CLLocationCoordinate2D(latitude: 41.00002, longitude: -109.05160),
                                                   CLLocationCoordinate2D(latitude: 36.99909, longitude: -109.04524),
                                                   CLLocationCoordinate2D(latitude: 37.00103, longitude: -114.05041)]
        
        let utahPolygon = MKPolygon(coordinates: coordinates, count: coordinates.count)
        mapView.add(utahPolygon)
    }
}
