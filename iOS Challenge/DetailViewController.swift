//
//  DetailViewController.swift
//  iOS Challenge
//
//  Created by Ali Ansari on 2019-01-20.
//  Copyright © 2019 Ali Ansari. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class DetailViewController: UIViewController {
  
  var collectionID: String!
  var collectionTitle: String!
  var collectionBody: String!
  var collectionImage: Data!
  var collects = [[String: AnyObject]]()
  var productIds = [String]()
  var products = [[String: AnyObject]]()
  
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet private weak var detailsCollectionTitle: UILabel!
  @IBOutlet private weak var detailsCollectionBody: UILabel!
  @IBOutlet private weak var detailsCollectionImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
      
      let width = (view.frame.size.width - 42.5) / 2
      let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
      layout.itemSize = CGSize(width: width, height: (width + 75))
      
      detailsCollectionTitle.text = collectionTitle
      detailsCollectionBody.text = collectionBody
      detailsCollectionImage.image = UIImage(data: collectionImage)
      CollectsData(collectionID: collectionID)
    }
  
  func CollectsData(collectionID: String) {
    let URL = "https://shopicruit.myshopify.com/admin/collects.json"
    let ACCESS_TOKEN = "c32313df0d0ef512ca64d5b336a0d7c6"
    let params : [String : String] = ["collection_id" : collectionID, "access_token" : ACCESS_TOKEN]
    
    Alamofire.request(URL, method: .get, parameters: params).responseJSON { (response) in
      if ((response.result.value) != nil) {
        let jsonData = JSON(response.result.value!)
        if let collectsData = jsonData["collects"].arrayObject {
          self.collects = collectsData as! [[String : AnyObject]]
        }
        if self.collects.count > 0 {
          self.collectionView?.reloadData()
        }
      }
      for product in self.collects {
        self.productIds.append(String(product["product_id"] as! Int))
      }
      let stringProductIds = self.productIds.joined(separator: ",")
      self.ProductsData(productIDs: stringProductIds)
    }
  }
  
  func ProductsData(productIDs: String) {
    let URL = "https://shopicruit.myshopify.com/admin/products.json"
    let ACCESS_TOKEN = "c32313df0d0ef512ca64d5b336a0d7c6"
    let params : [String : String] = ["ids" : productIDs, "access_token" : ACCESS_TOKEN]
    Alamofire.request(URL, method: .get, parameters: params).responseJSON { (response) in
      if ((response.result.value) != nil) {
        let jsonData = JSON(response.result.value!)
        if let productData = jsonData["products"].arrayObject {
          self.products = productData as! [[String : AnyObject]]
        }
        if self.products.count > 0 {
          self.collectionView?.reloadData()
        }
      }
      
    }
  }
  
}

extension DetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return products.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailViewCell", for: indexPath)
    
    let imageData = JSON(products[indexPath.row]["image"]!)
    let imageSrc = imageData["src"].stringValue
    let imageSrcUrl = URL(string: imageSrc)!
    let imageSrcData = try! Data(contentsOf: imageSrcUrl)
    if let colectionImage = cell.viewWithTag(200) as? UIImageView {
      colectionImage.image = UIImage(data: imageSrcData)
    }
    
    if let labelName = cell.viewWithTag(201) as? UILabel {
      labelName.text = products[indexPath.row]["title"] as? String
    }
    var inventoryCount = 0
    let variant = JSON(products[indexPath.row]["variants"]!)
    for n in 0...(variant.count - 1) {
      let inventoryQuantity = variant[n]["inventory_quantity"].intValue
      inventoryCount = inventoryCount + inventoryQuantity
    }
    if let labelInventory = cell.viewWithTag(202) as? UILabel {
      labelInventory.text = "Quantity: \(inventoryCount)"
    }
      return cell
  }
}
