//
//  serchResultViewCell.swift
//  WadizSearch
//
//  Created by yangjs on 2022/04/09.
//

import UIKit

class serchResultViewCell: UITableViewCell {
    @IBOutlet weak var resultImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
