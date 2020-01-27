//
//  PhotoCollectionViewCell.swift
//  Bopy
//
//  Created by bojack on 2019/12/22.
//  Copyright © 2019 bojack. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    var damageTypeText: String?
    var locationText: String?
    var descriptionText: String?
    var dateText: String?
    var imageURLText: String?
    var imageThumbnailURLText: String?
    var keyText: String?
}
