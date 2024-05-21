//
//  ProductDisplayViewController.swift
//  Swipe Application
//
//  Created by Ankita Mondal on 09/05/24.
//

import Foundation
import UIKit
class ProductDisplayViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var notFoundImg: UIImageView!
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var PdoductButton: UIButton!
    
    @IBOutlet weak var myTable: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    let productDataManager = ProductDataManager.shared

    var filterData:[Product] = []
    var products = [Product]()
    var search = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchProducts()
        myTable.delegate = self
        myTable.dataSource = self
        myTable.reloadData()
        searchBar.delegate = self
        products = ProductDataManager.shared.loadProducts()
        searchBar.isHidden = true
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        let searchIcon = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchButtonTapped))
        navigationItem.rightBarButtonItems = [addButton, searchIcon]
 
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.isHidden = true
        search = false
        filterData = products
        myTable.reloadData()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    @objc func searchButtonTapped() {
        
        searchBar.isHidden = false
               searchBar.showsCancelButton = true
               searchBar.becomeFirstResponder()
            
    }
   
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filterData = products
        } else {
            filterData = products.filter { $0.product_name.range(of: searchText, options: .caseInsensitive) != nil }
        }
        myTable.reloadData()
        
        if filterData.isEmpty {
            let noDataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: myTable.bounds.size.width, height: myTable.bounds.size.height))
           
            notFoundImg.image = UIImage(named: "th")
           
            myTable.backgroundView = notFoundImg
        } else {
            
        }
    }
    @objc func addButtonTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let addProductVC = storyboard.instantiateViewController(withIdentifier: "ProductDetailsViewController") as? ProductDetailsViewController {
                    navigationController?.pushViewController(addProductVC, animated: true)
                }
            
    }
  
        
    func fetchProducts() {
            
           // activityIndicator.startAnimating()
            let url = URL(string: "https://app.getswipe.in/api/public/get")!
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        let decodedProducts = try decoder.decode([Product].self, from: data)
                        DispatchQueue.main.async {
                            self.products = decodedProducts
                            self.filterData = decodedProducts
                            self.myTable.reloadData()
                        }
                    } catch {
                        print("Error decoding JSON: \(error)")
                    }
                }
            }.resume()
        }
    
    
    
    @IBAction func ProductButton(_ sender: UIButton) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let addProductVC = storyboard.instantiateViewController(withIdentifier: "ProductDetailsViewController") as? ProductDetailsViewController {
            navigationController?.pushViewController(addProductVC, animated: true)
        }
    }
    }
    
    
    


extension ProductDisplayViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return  filterData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! myTableViewCell
        cell.selectionStyle = .none
       
        let product = filterData[indexPath.row]// Assuming 'Product' is your model class
        cell.ProductPrice.text = "Price :"
        cell.ProductName.text = product.product_name
        cell.ProductCat.text = product.product_type
        cell.PriceValue.text = "\(product.price)" + " - Tax:" + "\(product.tax)"
        if let url = URL(string: product.image) {
                URLSession.shared.dataTask(with: url) { (data, response, error) in
                    if let data = data {
                        DispatchQueue.main.async {
                            cell.ProductImage.image = UIImage(data: data)
                        }
                    } else {
                        DispatchQueue.main.async {
                            cell.ProductImage.image = UIImage(named: "defaultImage")
                        }
                    }
                }.resume()
        } else {
                cell.ProductImage.image = UIImage(named: "th")
            }
            
            return cell
        }
        
    }

    
    
    

    
    




