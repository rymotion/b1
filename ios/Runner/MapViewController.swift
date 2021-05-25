//
//  MapViewController.swift
//  Runner
//
//  Created by Ryan Paglinawan on 4/8/19.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Flutter

class MapViewFactory: NSObject, FlutterPlatformViewFactory {
    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return UIMapView(frame, viewID: viewId, args: args)
    }
}

class UIMapView: NSObject, FlutterPlatformView {
    let frame: CGRect
    let viewId: Int64
    
    init(_ frame: CGRect, viewID: Int64, args: Any?) {
        self.viewId = viewID
        self.frame = frame
    }
    
    func view() -> UIView {
        return CustomMapView(frame: frame)
    }
}

class CustomMapView: MKMapView, CLLocationManagerDelegate, MKMapViewDelegate {
    let locationManager: CLLocationManager! = CLLocationManager()
    var currentUserLocation: CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    var _currentLocation: CLLocation?
    
    var _mkMapViewCamera: MKMapCamera?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        
        // TODO(rpaglinawan): add a guard and fail safe on first load
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.startUpdatingLocation()
        
        self.currentUserLocation = locationManager.location!.coordinate
        

        self.showsCompass = true
        self.showsUserLocation = true
        self.showsPointsOfInterest = false
        self.showsTraffic = false
        
        self._mkMapViewCamera = MKMapCamera.init(lookingAtCenter: currentUserLocation, fromDistance: 10.0, pitch: 10.0, heading: 90.0)
        self.camera = _mkMapViewCamera!
        print("\(currentUserLocation)")
        
        self.centerCoordinate = currentUserLocation
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CustomMapView {
//    func mapViewWillStartLoadingMap(_ mapView: MKMapView) {
//        <#code#>
//    }
//    func mapViewWillStartLocatingUser(_ mapView: MKMapView) {
//        
//    }
}

extension CustomMapView {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentUserLocation = locations.last!.coordinate
        print("currentLocation: \(_currentLocation)\n currentUserLocation: \(currentUserLocation)")
        self.camera.centerCoordinate = locations.last!.coordinate
        self.setCamera(MKMapCamera(lookingAtCenter: currentUserLocation, fromDistance: 10.0, pitch: 10.0, heading: 90.0), animated: true)
        self.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            manager.requestLocation()
            self.showsUserLocation = true
            break
        case .restricted:
            manager.stopUpdatingLocation()
            manager.requestWhenInUseAuthorization()
            self.showsUserLocation = false
            break
        case .denied:
            manager.stopUpdatingLocation()
            manager.requestWhenInUseAuthorization()
            self.showsUserLocation = false
            break
        default:
            manager.startUpdatingLocation()
            self.showsUserLocation = true
            break
        }
    }
}
