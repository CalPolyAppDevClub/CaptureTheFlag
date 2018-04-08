//
//  MapTestViewController.swift
//  CaptureTheFlag
//
//  Created by Joe Durand on 3/11/18.
//  Copyright © 2018 Joe Durand. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps

class MapTestViewController: UIViewController {
    
    override func loadView() {
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        view = mapView
    }
    
    
}
