//
//  ViewController.swift
//  geosniffit
//
//  Created by cgmckeever on 10/28/14.
//  Copyright (c) 2014 cgmckeever. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController,
    CLLocationManagerDelegate,
    AdaptersGooglePlacesDelegate
{
    let locationManager = CLLocationManager()
    let creepInterval = 0.2
    
    var googlePlaces: AdapterGooglePlaces? = nil
    var lastCreep: Double? = nil
    
    @IBOutlet var currentLocationLabel : UILabel!
    @IBOutlet var currentLocationLatTextField : UITextField!
    @IBOutlet var currentLocationLonTextField : UITextField!
    
    @IBOutlet var region1NameTextField : UITextField!
    @IBOutlet var region1LatTextField : UITextField!
    @IBOutlet var region1LonTextField : UITextField!
    
    @IBOutlet var region2NameTextField : UITextField!
    @IBOutlet var region2LatTextField : UITextField!
    @IBOutlet var region2LonTextField : UITextField!
    
    @IBOutlet var debuggerTextView : UITextView!
    
    @IBAction func addRegion(sender: AnyObject) {
        var nameTextField: UITextField?
        let dialog = UIAlertController(title: "Fencing!",
            message: "Name this Den of Sin",
            preferredStyle: UIAlertControllerStyle.Alert)
        dialog.addTextFieldWithConfigurationHandler({ textField in
            nameTextField = textField
            textField.placeholder = "Den of Sin"
        })
        dialog.addAction(UIAlertAction(title: "Add",
            style: UIAlertActionStyle.Default,
            handler: { (dialogAction: UIAlertAction!) in
                var regionName = nameTextField?.text
                self.setFenceRegion(self.currentLocationLatTextField,
                    lon: self.currentLocationLonTextField,
                    name: regionName!)
        }))
        dialog.addAction(UIAlertAction(title: "Cancel",
            style: UIAlertActionStyle.Default,
            handler: nil))
        self.presentViewController(dialog, animated: true, completion: nil)
    }
    
    @IBAction func startCreep(sender: AnyObject) {
        setFenceRegion(region1LatTextField,
            lon: region1LonTextField,
            name: region1NameTextField.text)
        setFenceRegion(region2LatTextField,
            lon: region2LonTextField,
            name: region2NameTextField.text)
        startMaxMonitor()
        debugger("Starting Creeper....")
    }
    
    @IBAction func stopCreep(sender: AnyObject) {
        debugger("Stopping Creeper....")
        stopMonitor()
    }
    
    @IBAction func clearRegions(sender: AnyObject) {
        debugger("Clearing Regions....")
        unwatchRegions()
    }
    
    @IBAction func listRegions(sender: AnyObject) {
        listRegions()
        debugger("Watched Regions....")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10.0
        
        googlePlaces = AdapterGooglePlaces(intervalSet: creepInterval)
        googlePlaces!.delegate = self
        
        debuggerTextView.text = ""
        debugger("debugger.....")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func unwatchRegions(){
        for region in locationManager.monitoredRegions
        {
            locationManager.stopMonitoringForRegion(region as CLRegion)
            debugger("Stopping: \(region.identifier)")
        }
    }
    
    func listRegions(){
        for region in locationManager.monitoredRegions
        {
            debugger("Monitoring: \(region.identifier)")
        }
    }

    func setFenceRegion(lat: UITextField, lon: UITextField, name: String ){
        var center = CLLocationCoordinate2D(latitude: lat.text.doubleValue(),
            longitude: lon.text.doubleValue())
        
        locationManager.startMonitoringForRegion(
            CLCircularRegion(circularRegionWithCenter: center,
                radius: 15.0,
                identifier: name))
    }
    
    func googlePlacesSearchResult(items: [GooglePlace])
    {
        debugger("Creep count: \(items.count)")
        for index in 0..<items.count
        {
            debugger("Close to? \(items[index].name)")
        }
    }
    
    func googlePlacesSearchError(error: String)
    {
        debugger("Google Error: \(error)")
    }
    
    func currentTS() -> Double {
        return NSDate().timeIntervalSince1970
    }
    
    func debugger(text: String){
        var current = debuggerTextView.text
        debuggerTextView.text = "\(text)\n\(current)"
    }
    
    func alert(message: String){
        debugger("alerting \(message)")
        let alerter = UILocalNotification()
        alerter.alertBody = message
        UIApplication.sharedApplication().presentLocalNotificationNow(alerter)
        
        let dialog = UIAlertController(title: "Fenced!",
            message: message,
            preferredStyle: UIAlertControllerStyle.Alert)
        dialog.addAction(UIAlertAction(title: "Cool",
            style: UIAlertActionStyle.Default,
            handler: nil))
        self.presentViewController(dialog, animated: true, completion: nil)
    }
    
    func startMinMonitor(){
        stopMonitor()
        locationManager.startMonitoringSignificantLocationChanges()
        debugger("MinMonitor....")
    }
    
    func startMaxMonitor(){
        stopMonitor()
        locationManager.startUpdatingLocation()
        debugger("MaxMonitor.....")
    }
    
    func stopMonitor(){
        locationManager.stopMonitoringSignificantLocationChanges()
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        debugger("sniffing.....")
        
        var lat = manager.location.coordinate.latitude
        var lon = manager.location.coordinate.longitude
        currentLocationLatTextField.text = NSString(format: "%f", lat)
        currentLocationLonTextField.text = NSString(format: "%f", lon)
        
        if lastCreep == nil ||
            (currentTS() - lastCreep!)/60 > creepInterval
        {
            debugger("creeping.....")
            lastCreep = currentTS()
            var cllocation = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            googlePlaces!.search(cllocation, radius: 20)
        }
        
    }
    
    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        alert("Welcome! \(region.identifier)")
        // could toggle minMonitor
    }
    
    func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
        alert("Sayonara \(region.identifier)")
        // could toggle MaxMonitor
    }
    
    func locationManager(manager: CLLocationManager!, didStartMonitoringForRegion region: CLRegion!) {
        debugger("Fenced! \(region.identifier)")
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Error while updating location " + error.localizedDescription)
    }


}

