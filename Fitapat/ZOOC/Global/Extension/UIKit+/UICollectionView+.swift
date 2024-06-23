//
//  UICollectionView+.swift
//  ZOOC
//
//  Created by 장석우 on 2023/10/06.
//

import UIKit

extension UICollectionView {
    func selectCell(at indexPath: IndexPath) {
        self.selectItem(at: indexPath,
                        animated: true,
                        scrollPosition: .centeredVertically)
        
    }
    
    func deselectCell(at indexPath: IndexPath) {
        self.deselectItem(at: indexPath,
                          animated: true)
      }
}
