//
//  SectionCell.swift
//  SystemFontManager
//
//  Created by HongXiangWen on 2020/8/26.
//  Copyright © 2020 WHX. All rights reserved.
//

import UIKit

class SectionCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var downloadBtn: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    
    var systemFont: SystemFont? {
        didSet {
            guard let systemFont = systemFont else { return }
            nameLabel.text = systemFont.displayName
            switch systemFont.state {
            case .didBegin:
                progressView.progress = 0
                downloadBtn.setTitle("下载中...", for: .normal)
                downloadBtn.isEnabled = false
            case .downloading(let progress):
                progressView.progress = progress / 100
                downloadBtn.setTitle("下载中...", for: .normal)
                downloadBtn.isEnabled = false
            case .didFinish(let error):
                if error != nil {
                    progressView.progress = 0
                    downloadBtn.setTitle("下载", for: .normal)
                    downloadBtn.isEnabled = true
                } else {
                    progressView.progress = 1
                    downloadBtn.setTitle("已下载", for: .normal)
                    downloadBtn.isEnabled = false
                }
            case .none:
                downloadBtn.setTitle(systemFont.isDownloaded ? "已下载" : "下载", for: .normal)
                downloadBtn.isEnabled = !systemFont.isDownloaded
                progressView.progress = systemFont.isDownloaded ? 1 : 0
            }
        }
    }
    
    var downloadCallback: (() -> Void)?
    
    @IBAction func downloadBtnClicked(_ sender: Any) {
        downloadCallback?()
    }
}
