//
//  PhotoCollectionViewController.swift
//  Bopy
//
//  Created by bojack on 2019/12/22.
//  Copyright © 2019 bojack. All rights reserved.
//

import UIKit
import FirebaseDatabase

private let reuseIdentifier = "Cell"

class PhotoCollectionViewController: UICollectionViewController, UISearchResultsUpdating {

    var searchController: UISearchController?
    let MAX_DATA_DICT_NUM: Int = 25
    var fireDataDict: [String:Any]?
    var filterDataDict: [String:Any]?
    var ref: DatabaseReference! = Database.database().reference().child("Damages")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // setup flow layout
        let width = (collectionView.bounds.width - 1) / 3
        let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout
        flowLayout?.itemSize = CGSize(width: width, height: width)
        flowLayout?.estimatedItemSize = .zero
        
        // get firebase data
        ref.observe(.value, with: { [weak self] (snapshot) in
            if let uploadDict = snapshot.value as? [String:Any] {
//[start-20191223-ben(debug)-add]//
//            print("uploadDict: ", uploadDict)
//[end-20191223-ben(debug)-add]//
                self?.fireDataDict = uploadDict
                self?.filterDataDict = self?.fireDataDict
                self?.collectionView!.reloadData()
            }
        })
        
        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if let dataDict = filterDataDict {
            if dataDict.count < MAX_DATA_DICT_NUM {
                return dataDict.count
            } else {
                return MAX_DATA_DICT_NUM
            }
        }
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCollectionViewCell
    
        // configure the image of the cell
        if let dataDict = filterDataDict {
            let keyArray = Array(dataDict.keys)
            if let data = dataDict[keyArray[indexPath.row]] as? NSDictionary {
                //
                // load all info from firebase
                //
                if let imageURLString = data["imageThumbnailURL"] as? String {
                    let request = URLRequest(url: URL(string: imageURLString)!)
                    let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
                        if error != nil {
                            print("Download Image Task Fail: \(error!.localizedDescription)")
                        } else if let imageData = data {
                            DispatchQueue.main.async {
                                cell.imageView.image = UIImage(data: imageData)
                            }
                        }
                    }
                    task.resume()
                }
                
                if let dateString  = data["date"] as? String {
                    cell.dateText = dateString
                }
                
                if let damageString = data["damage"] as? String {
                    cell.damageTypeText = damageString
                }
                
                if let locationString = data["location"] as? String {
                    cell.locationText = locationString
                }
                
                if let descriptionString = data["description"] as? String {
                    cell.descriptionText = descriptionString
                }
                
                if let imageURLString = data["imageURL"] as? String {
                    cell.imageURLText = imageURLString
                }
                
                if let imageThumbnailURLString = data["imageThumbnailURL"] as? String {
                    cell.imageThumbnailURLText = imageThumbnailURLString
                }
            }
        }
        return cell
    } // collectionView

    // MARK: - Search action
    @IBAction func searchAction(_ sender: Any) {
        if #available(iOS 11.0, *) {
            if navigationItem.searchController == nil {
                if searchController == nil {
                    searchController = UISearchController(searchResultsController: nil)
                } else {
                    searchController?.isActive = true
                }
                
                navigationItem.hidesSearchBarWhenScrolling = false
                navigationItem.searchController = searchController
                searchController?.searchResultsUpdater = self
                searchController?.dimsBackgroundDuringPresentation = false
                settingSearchController()
            } else {
                searchController?.dismiss(animated: true, completion: nil)
                navigationItem.searchController = nil
                collectionView.reloadData()
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    func settingSearchController() {
//        searchController?.definesPresentationContext = true
        searchController?.searchBar.placeholder = "請輸入關鍵字"
        searchController?.searchBar.searchBarStyle = .prominent
        self.definesPresentationContext = true
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            if searchText != "" {
                filterContent(for: searchText)
            } else {
                self.filterDataDict = self.fireDataDict
            }
            collectionView.reloadData()
        }
    }
    
    func filterContent(for searchText: String) {
        filterDataDict = fireDataDict?.filter({ (key, value) -> Bool in
            if let damageInfoDict = value as? NSDictionary {
                return (damageInfoDict["location"] as? String)?.contains(searchText) ?? false    ||
                      (damageInfoDict["damage"] as? String)?.contains(searchText) ?? false      ||
                      (damageInfoDict["description"] as? String)?.contains(searchText) ?? false  ||
                      (damageInfoDict["date"] as? String)?.contains(searchText) ?? false
            }
            return false
        })
    }
    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
