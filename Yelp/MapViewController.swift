//
//  MapViewController.swift
//  Yelp
//
//  Created by Tran, Leland on 4/9/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit


class MapViewController: UIViewController, FiltersViewControllerDelegate {

    var businesses : [Business]!
    
    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()

        loadMapView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String : AnyObject]) {
        let categories = filters["categories"] as? [String]
        let dealsIsOn = filters["deals"] as? Bool
        let sortMode = filters["sortMode"] as? YelpSortMode
        let distance = filters["distance"] as? Double
        print("distance: \(distance)")
        print("clearing annotations")
        clearAnnotations(from: mapView)
        Business.searchWithTerm(term: "Restaurants", sort: sortMode, categories: categories, deals: dealsIsOn, completion: {
            (businesses: [Business]?, error: Error?) -> Void in
            self.businesses = distance == nil ? businesses :businesses?.filter {
                (item: Business) -> Bool in
                let strArr = item.distance?.components(separatedBy: " ")
                let dist = Double(strArr![0])
                return dist! < distance!
            }
            print("filteredData: \(self.businesses)")
            self.loadMapView()
        })
    }
    
    func loadMapView(){
        let centerLocation = CLLocation(latitude: 37.783, longitude: -122.4167)
        goToLocation(centerLocation)
        addAnnotationByCoordinate(at: centerLocation.coordinate, title: "This is the center")
        for business in businesses {
            addAnnotationByAddress(at: business.address!, title: business.name!)
        }
    }
    
    func clearAnnotations(from map: MKMapView){
        for annotation in map.annotations {
            print("removing annotation: \(annotation.title!)")
            map.removeAnnotation(annotation)
        }
    }

    
    func goToLocation(_ location: CLLocation){
        let span = MKCoordinateSpanMake(0.1, 0.1)
        let region = MKCoordinateRegionMake(location.coordinate, span)
        mapView.setRegion(region, animated: false)
    }
    
    func addAnnotationByCoordinate(at coordinate: CLLocationCoordinate2D, title: String){
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = title
        mapView.addAnnotation(annotation)
    }
    
    func addAnnotationByAddress(at address: String, title: String){
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            if let placemarks = placemarks {
                if placemarks.count != 0 {
                    let coordinate = placemarks.first!.location!
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate.coordinate
                    annotation.title = title
                    self.mapView.addAnnotation(annotation)
                    
                }
            }
        }
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let navigationController = segue.destination as! UINavigationController
        if let filtersViewController = navigationController.topViewController as? FiltersViewController {
            filtersViewController.delegate = self
        } else if let businessesViewController = navigationController.topViewController as? BusinessesViewController {
            businessesViewController.businesses = businesses
            businessesViewController.filteredData = businesses
            businessesViewController.tableView.reloadData()
        }
    }
    

}
