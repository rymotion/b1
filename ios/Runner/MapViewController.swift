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
//    var iosMapView: MKMapView!
    let locationManager: CLLocationManager! = CLLocationManager()
    var currentUserLocation: CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    var currentLocation: CLLocation?
    
    var _mkMapViewCamera: MKMapCamera?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
//        iosMapView.delegate = self
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.startUpdatingLocation()
        
//        currentUserLocation = locationManager.location!.coordinate
        
//        guard let _mapView = self.iosMapView else {
//            return
//        }
//
//        self.iosMapView.showsCompass = true
//        self.iosMapView.showsUserLocation = true
//        self.iosMapView.showsPointsOfInterest = false
//        self.iosMapView.showsTraffic = false
        
//        self._mkMapViewCamera = MKMapCamera.init(lookingAtCenter: currentUserLocation, fromDistance: 10.0, pitch: 10.0, heading: 90.0)
//        self.iosMapView.camera = _mkMapViewCamera!
        print("\(currentUserLocation)")
        
//        self.iosMapView?.centerCoordinate = currentUserLocation
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
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        currentUserLocation = locations.last!.coordinate
//        print("currentLocation: \(currentLocation)\n currentUserLocation: \(currentUserLocation)")
////        self.iosMapView.camera.centerCoordinate = locations.last!.coordinate
////        self.iosMapView.setCamera(MKMapCamera(lookingAtCenter: currentUserLocation, fromDistance: 10.0, pitch: 10.0, heading: 90.0), animated: true)
//        self.locationManager.stopUpdatingLocation()
//    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            manager.requestLocation()
//            iosMapView.showsUserLocation = true
            break
        case .restricted:
            manager.stopUpdatingLocation()
            manager.requestWhenInUseAuthorization()
//            iosMapView.showsUserLocation = false
            break
        case .denied:
            manager.stopUpdatingLocation()
            manager.requestWhenInUseAuthorization()
//            iosMapView.showsUserLocation = false
            break
        default:
            manager.startUpdatingLocation()
//            iosMapView.showsUserLocation = true
            break
        }
    }
}
