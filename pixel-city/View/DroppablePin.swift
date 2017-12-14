//
//  DroppablePin.swift
//  pixel-city
//
//  Created by 張書涵 on 2017/12/12.
//  Copyright © 2017年 AliceChang. All rights reserved.
//

import UIKit
import MapKit

class DroppablePin: NSObject,MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var identifier:String
    init(coordinate:CLLocationCoordinate2D,identifer:String){
        self.coordinate = coordinate
        self.identifier = identifer
        super.init()
    }
}
