//
//  RowCell.swift
//  SystemFontManager
//
//  Created by HongXiangWen on 2020/8/26.
//  Copyright © 2020 WHX. All rights reserved.
//

import UIKit

class RowCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var exampleLabel: UILabel!
    
    var fontName: SystemFont.FontName? {
        didSet {
            guard let fontName = fontName else { return }
            nameLabel.text = fontName.style.displayName
            exampleLabel.text = "汉体书写信息技术标准相\n漢體書寫信息技術標準相"
            exampleLabel.font = UIFont(name: fontName.fontName, size: 15)
        }
    }
}
