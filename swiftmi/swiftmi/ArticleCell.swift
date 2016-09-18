//
//  ArticleCell.swift
//  swiftmi
//
//  Created by yangyin on 16/2/3.
//  Copyright © 2016年 swiftmi. All rights reserved.
//

import UIKit

class ArticleCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var sourceLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func loadData(_ item:AnyObject) {
        
        self.titleLabel.text = item.value(forKey: "title") as? String
        self.sourceLabel.text = item.value(forKey: "sourceName") as? String
        let pubTime = item.value(forKey: "createDate") as! Double
        let createDate = Date(timeIntervalSince1970: pubTime)
        self.dateLabel.text = Utility.formatDate(createDate)
    }

}
