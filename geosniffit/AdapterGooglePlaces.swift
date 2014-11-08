//
//  AdapterGooglePlaces.swift
//  geosniffit
//
//  Created by cgmckeever on 11/1/14.
//  Copyright (c) 2014 cgmckeever. All rights reserved.
//

import CoreLocation
import Foundation

struct GooglePlace {
    var name = String();
    var cllocation: CLLocationCoordinate2D;
}

protocol AdaptersGooglePlacesDelegate {
    func debugger(String)
    func googlePlacesSearchResult([GooglePlace])
    func googlePlacesSearchError(String)
}

class AdapterGooglePlaces {
    
    let URL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
    let KEY = ENTER_KEY_HERE
    var delegate: AdaptersGooglePlacesDelegate? = nil
    var lastRequestTime: Double? = nil
    var interval: Double? = nil
    
    init(intervalSet: Double)
    {
        interval = intervalSet
    }
    
    func search(cllocation: CLLocationCoordinate2D,
        radius: Int)
    {
        if clearForRequest() == true
        {
            lastRequestTime = NSDate().timeIntervalSince1970
            request(cllocation, radius: radius){ (items, errorDescription) -> Void in
                if errorDescription == ""
                {
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        self.delegate!.googlePlacesSearchResult(items)})
                }else
                {
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        self.delegate!.googlePlacesSearchError(errorDescription)})
                }
            
            }
        }
    }
    
    func clearForRequest() -> Bool {
        var cleared = false
        var rightNow = NSDate().timeIntervalSince1970
        if lastRequestTime == nil
            || (rightNow - lastRequestTime!)/60 > interval
        {
            cleared = true
        }
        return cleared
    }
    
    func request(cllocation: CLLocationCoordinate2D,
        radius: Int,
        callback: (items: Array<GooglePlace>, errorDescription : String) -> Void) {
            var urlString = "\(URL)location=\(cllocation.latitude),\(cllocation.longitude)&radius=\(radius)&key=\(KEY)"
            var url = NSURL(string: urlString)
            var session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
            
            session.dataTaskWithURL(url!,
                completionHandler: { (data: NSData!,
                response: NSURLResponse!,
                error: NSError!) -> Void in
                if error != nil
                {
                    callback(items: Array<GooglePlace>(), errorDescription: error.localizedDescription)
                }
                
                if let statusCode = response as? NSHTTPURLResponse {
                    if statusCode.statusCode == 200
                    {
                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                            callback(items: AdapterGooglePlaces.parseFromData(data), errorDescription: "")})
                    }else
                    {
                        callback(items: Array<GooglePlace>(), errorDescription: "Could not continue.  HTTP Status Code was \(statusCode)")
                    }
                }
            }).resume()
    }
    
    class func parseFromData(data : NSData) -> Array<GooglePlace> {
        var results = Array<GooglePlace>()
        var json = NSJSONSerialization.JSONObjectWithData(data,
                options: NSJSONReadingOptions.MutableContainers,
                error: nil) as NSDictionary
        
        var json_results = json["results"] as? Array<NSDictionary>
        
        for result in json_results! {
            var name = result["name"] as String
            var cllocation: CLLocationCoordinate2D!
            
            if let geometry = result["geometry"] as? NSDictionary {
                if let location = geometry["location"] as? NSDictionary {
                    var lat = location["lat"] as CLLocationDegrees
                    var long = location["lng"] as CLLocationDegrees
                    cllocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
                }
            }
            
            results.append(GooglePlace(name: name, cllocation: cllocation))
        }
        
        return results
    }

}




