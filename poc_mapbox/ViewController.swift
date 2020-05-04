//
//  ViewController.swift
//  poc_mapbox
//
//  Created by Lou Batier on 29/04/2020.
//  Copyright © 2020 Lou Batier. All rights reserved.
//

import UIKit
import Mapbox
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var image: UIImageView!
    
    let locationManager = CLLocationManager()
    lazy var mapView = MGLMapView()
    lazy var spots = [CLLocationCoordinate2D]()
    lazy var annotations = [MGLPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLocationManager()
        setupMap()
        view.bringSubviewToFront(addButton)
        
        spots = [
            CLLocationCoordinate2D(latitude: 37.787822, longitude: -122.405076),
            CLLocationCoordinate2D(latitude: 37.788136, longitude: -122.410065),
            CLLocationCoordinate2D(latitude: 37.781015, longitude: -122.408677)
        ]
        
        updateMapAnnotations()
        
    }

    func setupLocationManager() {
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func setupMap() {
        mapView = MGLMapView(frame: view.bounds)
        mapView.showsUserLocation = true
        mapView.delegate = self
        
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.setCenter(CLLocationCoordinate2D(latitude: locationManager.location!.coordinate.latitude, longitude: locationManager.location!.coordinate.longitude), zoomLevel: 15, animated: false)
        mapView.styleURL = URL(string: "mapbox://styles/loubatier/ck9s9jwa70afa1ipdyhuas2yk")
        view.addSubview(mapView)
    }
    
    @IBAction func addMarker(_ sender: UIButton) {
        let spot = locationManager.location!.coordinate
        spots.append(spot)
        
        updateMapAnnotations()
    }
    
    func updateMapAnnotations() {
        for spot in spots {
            let point = MGLPointAnnotation()
            point.coordinate = spot
            point.title = "\(spot.latitude), \(spot.longitude)"
            annotations.append(point)
        }
        
        mapView.addAnnotations(annotations)
    }
    
}

extension ViewController: MGLMapViewDelegate {
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        let camera = MGLMapCamera(lookingAtCenter: annotation.coordinate, altitude: 4500, pitch: 15, heading: 180)
        mapView.fly(to: camera, completionHandler: nil)
    }
    
    // TODO : utiliser un offset ou mettre un padding transparent dans l'image pour que le bas du pin soit centré sur le point
    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        var annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: "\(annotation.coordinate.latitude)")
        annotationImage = MGLAnnotationImage(image: UIImage(named: "pin")!, reuseIdentifier: "\(annotation.coordinate.latitude)")
        
        return annotationImage
    }
    
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else {
            return
        }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
}

