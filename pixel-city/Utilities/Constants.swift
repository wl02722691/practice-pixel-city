//
//  Constants.swift
//  pixel-city
//
//  Created by 張書涵 on 2017/12/13.
//  Copyright © 2017年 AliceChang. All rights reserved.
//

import UIKit

    let apiKey = "5c46e6fcec431a550d9622ab901c8b0b"
func flickrUrl(forApiKey key:String,withAnnotation annotation:DroppablePin,andNumberOfPhoto number:Int) -> String{
    let url = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=ml&per_page=\(number)&format=json&nojsoncallback=1"
    print(url)
    return url
}

