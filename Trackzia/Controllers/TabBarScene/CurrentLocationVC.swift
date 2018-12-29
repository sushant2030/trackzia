//
//  CurrentLocationViewController.swift
//  Trackzia
//
//  Created by Rohan Bhale on 23/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import UIKit
import MapKit

class CurrentLocationVC: UIViewController {
    @IBOutlet var liveButton: UIButton!
    @IBOutlet var mapView: MKMapView!
    var region:MKCoordinateRegion!
    override func viewDidLoad() {
        super.viewDidLoad()
        liveButton.layer.cornerRadius = 7.0
        region = mapView.region
    }
    
    private func registerDelegatesSetupViews() {
        mapView.delegate = self
        mapView.showsUserLocation = true
    }
    
    func setupViewWithLatAndLong(lat:Float,long:Float){
        region.center = CLLocationCoordinate2DMake(CLLocationDegrees(lat), CLLocationDegrees(long))
        region.span.longitudeDelta /= 1.0
        region.span.latitudeDelta /= 1.0
        mapView .setRegion(region, animated: false)
        
    }
    
    func setupMapWIthMultipleAnnotations(locations:[LocationDetailModel]) {
        let annotations = locations.map { location -> MKAnnotation in
            let annotation = MKPointAnnotation()
            annotation.title = location.title
            let lat = Double(location.latitude);
            let long = Double(location.longitude)
            annotation.coordinate = CLLocationCoordinate2D(latitude: lat ?? 0.0, longitude: long ?? 0.0)
            return annotation
        }
        mapView.addAnnotations(annotations)
    }
}

extension CurrentLocationVC : MKMapViewDelegate {
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        
    }
    
    func mapViewWillStartRenderingMap(_ mapView: MKMapView) {
        
    }
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        
    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
    }
}

