//
//  ViewController.swift
//  SystemFontManager
//
//  Created by HongXiangWen on 2020/8/25.
//  Copyright © 2020 WHX. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SystemFontManager.initFonts { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    private func downloadFont(_ font: SystemFont, at indexPath: IndexPath) {
        SystemFontManager.shared.downloadSystemFont(font) { [weak self] (aFont) in
            switch aFont.state {
            case .didBegin, .downloading(_):
                self?.tableView.reloadRows(at: [indexPath], with: .none)
            case .didFinish(_):
                self?.tableView.reloadData()
            case .none:
                break
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if SystemFontManager.shared.isFontInitialized {
            return SystemFontManager.shared.systemFonts.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let font = SystemFontManager.shared.systemFonts[section]
        if font.isDownloaded {
            return font.fontNames.count + 1
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SectionCell", for: indexPath) as! SectionCell
            let font = SystemFontManager.shared.systemFonts[indexPath.section]
            cell.systemFont = font
            cell.downloadCallback = { [unowned self] in
                self.downloadFont(font, at: indexPath)
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RowCell", for: indexPath) as! RowCell
            cell.fontName = SystemFontManager.shared.systemFonts[indexPath.section].fontNames[indexPath.row - 1]
            return cell
        }
    }
}

