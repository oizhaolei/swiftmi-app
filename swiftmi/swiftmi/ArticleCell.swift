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

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func loadData(item:AnyObject) {
        
        self.titleLabel.text = item.valueForKey("title") as? String
        self.sourceLabel.text = item.valueForKey("sourceName") as? String
        let pubTime = item.valueForKey("createDate") as! Double
        let createDate = NSDate(timeIntervalSince1970: pubTime)
        self.dateLabel.text = Utility.formatDate(createDate)
    }

}
