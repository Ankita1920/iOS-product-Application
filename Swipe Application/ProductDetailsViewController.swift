//
//  ProductDetailsViewController.swift
//  Swipe Application
//
//  Created by Ankita Mondal on 09/05/24.
//

import Foundation
import UIKit
class ProductDetailsViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var ScrollView: UIScrollView!
    
    @IBOutlet weak var productCategory: UILabel!
    
    @IBOutlet weak var Category: UILabel!
    
    @IBOutlet weak var ProductImage: UIImageView!
    
    
    @IBOutlet weak var ProductName: UILabel!
    
    @IBOutlet weak var productTxt: UITextField!
    
    @IBOutlet weak var ProductPrice: UILabel!
    
    
    @IBOutlet weak var PriceAmt: UITextField!
    
    @IBOutlet weak var ProductTax: UILabel!
    
    @IBOutlet weak var taxValue: UITextField!
    
    @IBOutlet weak var ProductButton: UIButton!
    
    @IBOutlet weak var editcategory: UIButton!
    
    @IBOutlet weak var ImageEdit: UIButton!
    let productDataManager = ProductDataManager.shared
    var products = [Product]()
    var selectedImage: UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()
        ProductImage.image = UIImage(named: "th")
        if #available(iOS 14.0, *) {
            editcategory.showsMenuAsPrimaryAction = true
            editcategory.menu = addMenuItems()
        } else {
            // Fallback on earlier versions
        }
        productTxt.delegate = self
        PriceAmt.delegate = self
        taxValue.delegate = self
        ScrollView.contentSize = CGSize(width: ScrollView.frame.size.width, height: 1000)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
        
    
    @objc func newProductAdded(_ notification: Notification) {
        // Reload or update the product list when a new product is added
        products = productDataManager.loadProducts()
        
    }
    func to_call_when_keyboard_appear(notification: NSNotification, ScrollView: UIScrollView) {
        let userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = ScrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 70
        ScrollView.contentInset = contentInset
    }
    func to_call_when_keyboard_Disappear(notification:NSNotification,ScrollView:UIScrollView){
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        ScrollView.contentInset = contentInset
    }
    @objc func keyboardWillShow(notification:NSNotification) {
        to_call_when_keyboard_appear(notification: notification, ScrollView: ScrollView)
    }
    
    @objc func keyboardWillHide(notification:NSNotification) {
        to_call_when_keyboard_Disappear(notification: notification, ScrollView: ScrollView)
    }

    
    @IBAction func PrdTapped(_ sender: UIButton) {
        guard let productName = productTxt.text, !productName.isEmpty else {
            displayAlert(message: "Please enter product name.")
            return
        }
        
        guard let productPriceStr = PriceAmt.text, let productPrice = Double(productPriceStr) else {
            displayAlert(message: "Please enter valid product price.")
            return
        }
        
        guard let productTaxStr = taxValue.text, let productTax = Double(productTaxStr) else {
            displayAlert(message: "Please enter valid product tax.")
            return
        }
        
        guard let productCategory = Category.text, !productCategory.isEmpty else {
            displayAlert(message: "Please select product category.")
            return
        }
//        var imageBase64: String?
//        if let productImage = selectedImage, let imageData = productImage.pngData() {
//            imageBase64 = imageData.base64EncodedString()
//        }
        
        // Prepare data for POST request
        let productData: [String: Any] = [
            "product_name": productName,
            "price": productPrice,
            "tax": productTax,
            "product_type": productCategory
//            "productImage": imageBase64 ?? ""
            // Add additional fields if required
        ]
        guard let url = URL(string: "https://app.getswipe.in/api/public/add") else {
            displayAlert(message: "Invalid API endpoint.")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded charset=utf-8", forHTTPHeaderField: "Content-Type")
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: productData, options: .prettyPrinted)
        } catch {
            displayAlert(message: "Error encoding product data: \(error.localizedDescription)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            guard let self = self else { return }
            
            if let error = error {
                self.displayAlert(message: "Error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                self.displayAlert(message: "No data received from server.")
                return
            }
            
            let newProduct = Product(image: "", price: productPrice, product_name: productName, product_type: productCategory, tax: productTax)
            
            if let productDisplayVC = self.navigationController?.viewControllers.first(where: { $0 is ProductDisplayViewController }) as? ProductDisplayViewController {
                productDisplayVC.products.append(newProduct)
                DispatchQueue.main.async {
                    self.displayAlert(message: "Product added successfully.")
                }
            } else {
                DispatchQueue.main.async {
                    self.displayAlert(message: "ProductDisplayViewController not found.")
                }
            }
            NotificationCenter.default.post(name: Notification.Name("NewProductAdded"), object: nil)

            
        }.resume()
       
        
    }
    func displayAlert(message: String) {
         let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
         alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
         present(alert, animated: true, completion: nil)
     }
    
    
    @IBAction func Imagechnge(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
               imagePicker.delegate = self
               imagePicker.sourceType = .photoLibrary
               imagePicker.allowsEditing = true
               present(imagePicker, animated: true, completion: nil)
    }
    func addMenuItems()-> UIMenu{
        // Define the menu items based on the selected category or any other condition
        let menuItems = UIMenu(title: "", options: .displayInline, children: [
            UIAction(title: "Mac", image: nil, handler: { (_) in
                self.handleMenuItemSelection(title: "Mac")
            }),
            UIAction(title: "Mobile", image: nil, handler: { (_) in
                self.handleMenuItemSelection(title: "Mobile")
            }),
            UIAction(title: "Card", image: nil, handler: { (_) in
                self.handleMenuItemSelection(title: "Card")
            }),
            UIAction(title: "Airpods", image: nil, handler: { (_) in
                self.handleMenuItemSelection(title: "Airpods")
            }),
            UIAction(title: "SmartWatch", image: nil, handler: { (_) in
                self.handleMenuItemSelection(title: "SmartWatch")
            }),
            UIAction(title: "Desktop", image: nil, handler: { (_) in
                self.handleMenuItemSelection(title: "Desktop")
            })
        ])
        return menuItems
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            ProductImage.image = pickedImage
            selectedImage = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }

    func handleMenuItemSelection(title: String) {
        Category.text = title
        guard let menu = editcategory.menu
        else {
            return
        }
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder() // Dismiss the keyboard
            return true
        }
}



