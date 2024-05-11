//
//  TableViewCell.swift
//  Swipe Application
//
//  Created by Ankita Mondal on 09/05/24.
//

import UIKit

class myTableViewCell: UITableViewCell {
    
    @IBOutlet weak var ProductImage: UIImageView!
    @IBOutlet weak var ProductName: UILabel!
    @IBOutlet weak var ProductPrice: UILabel!
    
    @IBOutlet weak var PriceValue: UILabel!
    @IBOutlet weak var ProductCat: UILabel!
    override func awakeFromNib() {
        //etupCell()
    }

    func setupCell() {
        
        contentView.layer.cornerRadius = 10
     contentView.layer.masksToBounds = true

    }
}
