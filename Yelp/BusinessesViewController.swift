//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, FiltersViewControllerDelegate
{
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var searchBar: UISearchBar!
    var businesses: [Business]!
    var filteredData: [Business]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        
        searchBar = UISearchBar()
        print("searchBar: \(searchBar)") // prints out searchBar memory address and other info
        searchBar.sizeToFit() // does not fail
        searchBar.delegate = self
        
        navigationItem.titleView = searchBar
        
        Business.searchWithTerm(term: "Thai", completion: { (businesses: [Business]?, error: Error?) -> Void in
            
            self.businesses = businesses
            self.tableView.reloadData()
            if let businesses = businesses {
                for business in businesses {
                    print(business.name!)
                    print(business.address!)
                    print(business.distance!)
                }
                self.businesses = businesses
                self.filteredData = self.businesses
            }
            
        })
        
        
        /* Example of Yelp search with more search options specified
         Business.searchWithTerm("Restaurants", sort: .Distance, categories: ["asianfusion", "burgers"], deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
         self.businesses = businesses
         
         for business in businesses {
         print(business.name!)
         print(business.address!)
         }
         }
         */
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filteredData != nil {
            return filteredData.count
        }
        else {
            if businesses != nil {
                return businesses!.count
            }
            else {
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessCell", for: indexPath as IndexPath) as! BusinessCell
        
//        cell.business = businesses[indexPath.row]
        cell.business = filteredData[indexPath.row]
        
        return cell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchBar.showsCancelButton = true
        filteredData = searchText.isEmpty ? businesses : businesses.filter { (item: Business) -> Bool in
            return item.name?.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        tableView.reloadData()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
//        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let navigationConroller = segue.destination as! UINavigationController
        if let filtersViewController = navigationConroller.topViewController as? FiltersViewController{
        
            filtersViewController.delegate = self
        }
        else if let mapViewController = navigationConroller.topViewController as? MapViewController {
            // set delegate here
        }
        
    }
    
    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String : AnyObject]) {
        let categories = filters["categories"] as? [String]
        let dealsIsOn = filters["deals"] as? Bool
        let sortMode = filters["sortMode"] as? YelpSortMode
        let distance = filters["distance"] as? Double
        print("distance: \(distance)")
        Business.searchWithTerm(term: "Restaurants", sort: sortMode, categories: categories, deals: dealsIsOn, completion: {
                (businesses: [Business]?, error: Error?) -> Void in
                self.businesses = businesses
                self.filteredData = distance == nil ? self.businesses :self.businesses?.filter {
                    (item: Business) -> Bool in
                    let strArr = item.distance?.components(separatedBy: " ")
                    let dist = Double(strArr![0])
                    return dist! < distance!
                }
                print("filteredData: \(self.filteredData)")
                self.tableView.reloadData()
        })
    }
    
}
