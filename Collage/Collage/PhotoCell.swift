//
//  PhotoCell.swift
//  Collage
//
//  Created by ming on 2022/11/24.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var preview: UIImageView!
    var representedAssetIdentifier: String!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        preview.image = nil
    }
    
    func flash() {
        preview.alpha = 0
        setNeedsDisplay()
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.preview.alpha = 1
        }
    }
}
