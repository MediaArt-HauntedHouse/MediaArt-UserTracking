//
//  ViewController.swift
//  MediaArt-UserTracking
//
//  Created by Masaki Kobayashi on 2014/10/05.
//  Copyright (c) 2014年 Masaki Kobayashi. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {

    @IBOutlet weak var connection_status: UILabel!
    @IBOutlet weak var beacons: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var region: UILabel!

    var myLocationManager:CLLocationManager!
    var myBeaconRegion:CLBeaconRegion!
    var myTableView: UITableView!
    var myIds: NSMutableArray!
    var myUuids: NSMutableArray!

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        myLocationManager = CLLocationManager()
        myLocationManager.delegate = self

        let status = CLLocationManager.authorizationStatus()

        if(status == CLAuthorizationStatus.NotDetermined) {
            self.myLocationManager.requestAlwaysAuthorization();
        }

        let uuid:NSUUID? = NSUUID(UUIDString: "FF2BB40C-6C0E-1801-A386-001C4DB9EE23")
        let identifierStr:NSString = ""

        myBeaconRegion = CLBeaconRegion(proximityUUID:uuid, identifier:identifierStr)
        myBeaconRegion.notifyEntryStateOnDisplay = true
        myBeaconRegion.notifyOnEntry = true
        myBeaconRegion.notifyOnExit = true

        myIds = NSMutableArray()
        myUuids = NSMutableArray()
        
        self.beacons.text = "\(myIds.count)"
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        var statusStr = "";
        switch (status) {
        case .NotDetermined:
            statusStr = "NotDetermined"
        case .Restricted:
            statusStr = "Restricted"
        case .Denied:
            statusStr = "Denied"
        case .Authorized:
            statusStr = "Authorized"
        case .AuthorizedWhenInUse:
            statusStr = "AuthorizedWhenInUse"
        }

        self.status.text = "Status: \(statusStr)"
        
        manager.startMonitoringForRegion(myBeaconRegion);
    }
    
    func locationManager(manager: CLLocationManager!, didStartMonitoringForRegion region: CLRegion) {
        manager.requestStateForRegion(myBeaconRegion)
    }
    
    func locationManager(manager: CLLocationManager!, didDetermineState state: CLRegionState, forRegion inRegion: CLRegion!) {
        switch (state) {
            case .Inside:
                manager.startRangingBeaconsInRegion(myBeaconRegion);
                self.region.text = "inside"
                break;
                
            case .Outside:
                self.region.text = "outside"
                break;
                
            case .Unknown:
                self.region.text = "unknown"
            default:
                
                break;
        }
    }

    func locationManager(
        manager: CLLocationManager!,
        didRangeBeacons beacons: NSArray!,
        inRegion region: CLBeaconRegion!)
    {
        myIds = NSMutableArray()
        myUuids = NSMutableArray()
        var params: [String: AnyObject] = [:]

        if(beacons.count > 0){
            for var i = 0; i < beacons.count; i++ {

                var beacon = beacons[i] as CLBeacon
                let beaconUUID = beacon.proximityUUID;
                let minorID = beacon.minor;
                let majorID = beacon.major;
                let rssi = beacon.rssi;
                var bs = "\(beacon)";
                var pro = bs.componentsSeparatedByString(",")[3]
                var pro_num = pro.componentsSeparatedByString("+/- ")[1]
                var proximity = pro_num.componentsSeparatedByString("m")[0];

                params["\(i)"] = [
                    "uuid": "\(beaconUUID.UUIDString)",
                    "major": "\(majorID)",
                    "minor": "\(minorID)",
                    "rssi": "\(rssi)",
                    "proximity": "\(proximity)"
                ]
                
                let myBeaconId = "\(rssi)  Proximity: \(proximity) MajorId: \(majorID) MinorId: \(minorID)"
                myIds.addObject(myBeaconId)
                myUuids.addObject(beaconUUID.UUIDString)
                self.beacons.text = "\(myIds.count)"
                tableView.reloadData()
            }
            self.connection_status.textColor = UIColor.blueColor()
            Alamofire
                .request(
                    .POST,
                    "http://makky.io:3000/map",
                    parameters: ["beacon":params],
                    encoding:ParameterEncoding.JSON
                )
                .response{
                    (request, response, data, error) in
                    print(data)
                    print(response)
                    print(error)
                    self.connection_status.textColor = UIColor.whiteColor()
            }
        }
    }

    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        NSLog("didEnterRegion");
        manager.startRangingBeaconsInRegion(myBeaconRegion);
    }

    func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
        NSLog("didExitRegion");
        manager.stopRangingBeaconsInRegion(myBeaconRegion);
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myIds.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")

        cell.textLabel.sizeToFit()
        cell.textLabel.text = "\(myIds[indexPath.row])"

        cell.detailTextLabel?.text = "\(myUuids[indexPath.row])"
        cell.detailTextLabel?.textColor = UIColor.grayColor()
        cell.detailTextLabel?.font = UIFont.systemFontOfSize(10)
        
        return cell
    }
}