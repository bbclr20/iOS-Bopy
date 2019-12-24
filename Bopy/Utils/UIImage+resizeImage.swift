//
//  UIImage+resizeImage.swift
//  Bopy
//
//  Created by bojack on 2019/12/23.
//  Copyright © 2019 bojack. All rights reserved.
//

import UIKit

extension UIImage {
    
    func resizeImage(newWidth: CGFloat) -> UIImage? {

        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
    
}
