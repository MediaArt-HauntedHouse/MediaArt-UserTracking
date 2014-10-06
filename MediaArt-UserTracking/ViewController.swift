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

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate{
    
    @IBOutlet weak var connection_status: UILabel!
    @IBOutlet weak var beacons: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var myLocationManager:CLLocationManager!
    var myBeaconRegion:CLBeaconRegion!
    var myTableView: UITableView!
    var myIds: NSMutableArray!
    var myUuids: NSMutableArray!
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        myLocationManager = CLLocationManager()

        myLocationManager.delegate = self

        let status = CLLocationManager.authorizationStatus()
        
        // 認証が得られていない場合は、認証ダイアログを表示
        if(status == CLAuthorizationStatus.NotDetermined) {
            self.myLocationManager.requestAlwaysAuthorization();
        }

        let uuid:NSUUID? = NSUUID(UUIDString: "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")
        let identifierStr:NSString = ""

        myBeaconRegion = CLBeaconRegion(proximityUUID:uuid, identifier:identifierStr)
        myBeaconRegion.notifyEntryStateOnDisplay = true
        myBeaconRegion.notifyOnEntry = true
        myBeaconRegion.notifyOnExit = true

        myIds = NSMutableArray()
        myUuids = NSMutableArray()
        
        self.beacons.text = "\(myIds.count)"
    }
    
    // (Delegate) 認証のステータスがかわったら呼び出される.
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        println("didChangeAuthorizationStatus")
        
        // 認証のステータスをログで表示
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
        println(" CLAuthorizationStatus: \(statusStr)")
        self.status.text = "Status: \(statusStr)"
        
        manager.startMonitoringForRegion(myBeaconRegion);
    }
    
    // (Delegate): LocationManagerがモニタリングを開始したというイベントを受け取る.
    func locationManager(manager: CLLocationManager!, didStartMonitoringForRegion region: CLRegion) {
        
        println("didStartMonitoringForRegion")
        
        //この時点でビーコンがすでにRegion内に入っている可能性があるので、その問い合わせを行う
        manager.requestStateForRegion(myBeaconRegion)
    }
    
    // (Delegate): 現在リージョン内にいるかどうかの通知を受け取る
    func locationManager(manager: CLLocationManager!, didDetermineState state: CLRegionState, forRegion inRegion: CLRegion!) {
        
        println("locationManager: didDetermineState \(state)")
        
        switch (state) {
            
        case .Inside:
            println("CLRegionStateInside:");
            // (Delegate didRangeBeacons: STEP6)
            manager.startRangingBeaconsInRegion(myBeaconRegion);
            break;
            
        case .Outside:
            println("CLRegionStateOutside:");
            // 外にいる、またはUknownの場合はdidEnterRegionが適切な範囲内に入った時に呼ばれるため処理なし。
            break;
            
        case .Unknown:
            println("CLRegionStateUnknown:");
            // 外にいる、またはUknownの場合はdidEnterRegionが適切な範囲内に入った時に呼ばれるため処理なし。
        default:
            
            break;
            
        }
    }

    func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: NSArray!, inRegion region: CLBeaconRegion!) {
        myIds = NSMutableArray()
        myUuids = NSMutableArray()

        if(beacons.count > 0){
            
            for var i = 0; i < beacons.count; i++ {

                var beacon = beacons[i] as CLBeacon
                let beaconUUID = beacon.proximityUUID;
                let minorID = beacon.minor;
                let majorID = beacon.major;
                let rssi = beacon.rssi;
                var proximity = ""

                //println("UUID: \(beaconUUID.UUIDString)");
                //println("minorID: \(minorID)");
                //println("majorID: \(majorID)");
                //println("RSSI: \(rssi)");
                
                switch (beacon.proximity) {
                    case CLProximity.Unknown:
                        println("Proximity: Unknown");
                        proximity = "Unknown"
                        break;
                        
                    case CLProximity.Far:
                        println("Proximity: Far");
                        proximity = "Far"
                        break;
                        
                    case CLProximity.Near:
                        println("Proximity: Near");
                        proximity = "Near"
                        break;
                        
                    case CLProximity.Immediate:
                        println("Proximity: Immediate");
                        proximity = "Immediate"
                        break;
                }
                
                let myBeaconId = "\(rssi)  Proximity:\(proximity) MajorId: \(majorID) MinorId: \(minorID)"
                myIds.addObject(myBeaconId)
                myUuids.addObject(beaconUUID.UUIDString)
                self.beacons.text = "\(myIds.count)"
                tableView.reloadData()
                
                self.connection_status.textColor = UIColor.blueColor()
                Alamofire.request(.GET, "http://makky.io")
                    .response { (request, response, data, error) in
                        println(request)
                        println(response)
                        println(error)
                        self.connection_status.textColor = UIColor.whiteColor()
                }
                
                
            }
        }
    }
    
    // (Delegate) リージョン内に入ったというイベントを受け取る
    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        NSLog("didEnterRegion");
        manager.startRangingBeaconsInRegion(myBeaconRegion);
    }

    // (Delegate) リージョンから出たというイベントを受け取る
    func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
        NSLog("didExitRegion");
        manager.stopRangingBeaconsInRegion(myBeaconRegion);
    }

    // セルの行数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myIds.count
    }
    
    //セルの内容
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")

        cell.textLabel?.sizeToFit()
        cell.textLabel?.text = "\(myIds[indexPath.row])"

        cell.detailTextLabel?.text = "\(myUuids[indexPath.row])"
        cell.detailTextLabel?.textColor = UIColor.grayColor()
        cell.detailTextLabel?.font = UIFont.systemFontOfSize(10)
        
        return cell
    }
}
