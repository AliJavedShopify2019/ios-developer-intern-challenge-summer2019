//
//  ViewController.swift
//  iOS Challenge
//
//  Created by Ali Ansari on 2019-01-20.
//  Copyright © 2019 Ali Ansari. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class ViewController: UIViewController {

  @IBOutlet weak var collectionView: UICollectionView!
  
  var customCollectionsData = [[String: AnyObject]]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let width = (view.frame.size.width - 42.5) / 2
    let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
    layout.itemSize = CGSize(width: width, height: (width + 60))
    self.CustomCollectionsData()
  }
  
  func CustomCollectionsData() {
    let customCollectionsURL = URL(string: "https://shopicruit.myshopify.com/admin/custom_collections.json?page=1&access_token=c32313df0d0ef512ca64d5b336a0d7c6")
    Alamofire.request(customCollectionsURL!).validate().responseJSON { (response) in
      if ((response.result.value) != nil) {
        let jsonData = JSON(response.result.value!)
        if let customCollections = jsonData["custom_collections"].arrayObject {
          self.customCollectionsData = customCollections as! [[String : AnyObject]]
        }
        if self.customCollectionsData.count > 0 {
          self.collectionView?.reloadData()
        }
      }
    }
  }
  
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return customCollectionsData.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath)
    let customCollection = customCollectionsData[indexPath.row]
    if let label = cell.viewWithTag(100) as? UILabel {
      let source = customCollection["title"] as? String
      label.text = source!.replacingOccurrences(of: " collection", with: "")
    }
    let imageData = JSON(customCollectionsData[indexPath.row]["image"]!)
    let imageSrc = imageData["src"].stringValue
    let imageSrcUrl = URL(string: imageSrc)!
    let imageSrcData = try! Data(contentsOf: imageSrcUrl)
    if let colectionImage = cell.viewWithTag(102) as? UIImageView {
      colectionImage.image = UIImage(data: imageSrcData)
    }
    
    return cell
  }
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "DetailSegue" {
      if let dest = segue.destination as? DetailViewController, let index = collectionView.indexPathsForSelectedItems?.first {
        let collectionID = String(customCollectionsData[index.row]["id"] as! Int)
        let collectionTitle = customCollectionsData[index.row]["title"] as! String
        let collectionBody = customCollectionsData[index.row]["body_html"] as! String
        let imageData = JSON(customCollectionsData[index.row]["image"]!)
        let imageSrc = imageData["src"].stringValue
        let imageSrcUrl = URL(string: imageSrc)!
        let imageSrcData = try! Data(contentsOf: imageSrcUrl)
        dest.collectionID = collectionID
        dest.collectionTitle = collectionTitle
        dest.collectionBody = collectionBody
        dest.collectionImage = imageSrcData
      }
    }
  }
  
}

