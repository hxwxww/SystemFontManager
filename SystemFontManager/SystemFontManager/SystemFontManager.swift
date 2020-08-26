//
//  SystemFontManager.swift
//  SystemFontManager
//
//  Created by HongXiangWen on 2020/8/25.
//  Copyright © 2020 WHX. All rights reserved.
//

import UIKit

class SystemFontManager: NSObject {
        
    private(set) var isFontInitialized: Bool = false

    private(set) var systemFonts: [SystemFont] = []
    
    private let downloadedFontsKey = "com.whx.sfm.fonts"
    
    private var downloadedFonts: [String] {
        set {
            UserDefaults.standard.set(newValue, forKey: downloadedFontsKey)
        }
        get {
            UserDefaults.standard.array(forKey: downloadedFontsKey) as? [String] ?? ["苹方"]
        }
    }
    
    static let shared = SystemFontManager()
    private override init() {
        super.init()
    }
    
    static func initFonts(completion: (() -> Void)?) {
        let manager = SystemFontManager.shared
        manager.systemFonts = SystemFont.loadFonts()
        let downloadedFonts = manager.downloadedFonts
        let group = DispatchGroup()
        for font in manager.systemFonts {
            if downloadedFonts.contains(font.displayName) {
                group.enter()
                manager.downloadSystemFont(font) { (aFont) in
                    if aFont.isFinished {
                        group.leave()
                    }
                }
            }
        }
        group.notify(queue: DispatchQueue.main) {
            manager.isFontInitialized = true
            completion?()
        }
    }
    
    func isDownloadedFont(_ font: SystemFont) -> Bool {
        let fontName = font.fontNames[0].fontName
        if let font = UIFont(name: fontName, size: 12) {
            return font.fontName == fontName || font.familyName == fontName
        } else {
            return false
        }
    }
    
    private func storeDownloadedFont(_ font: SystemFont) {
        if !downloadedFonts.contains(font.displayName) {
            downloadedFonts.append(font.displayName)
        }
    }
    
    func downloadSystemFont(_ font: SystemFont, handler: ((SystemFont) -> Void)?) {
        if isDownloadedFont(font) {
            storeDownloadedFont(font)
            font.state = .didFinish(nil)
            handler?(font)
            return
        }
        let fontName = font.fontNames[0].fontName
        let desc = CTFontDescriptorCreateWithAttributes([kCTFontNameAttribute: fontName] as CFDictionary)
        CTFontDescriptorMatchFontDescriptorsWithProgressHandler([desc] as CFArray, nil) { (state, info) -> Bool in
            switch state {
            case .didBegin:
                font.state = .didBegin
                DispatchQueue.main.async {
                    handler?(font)
                }
            case .downloading:
                let key = Unmanaged.passRetained(kCTFontDescriptorMatchingPercentage).autorelease().toOpaque()
                if let value = CFDictionaryGetValue(info, key) {
                    let progress = Unmanaged<NSNumber>.fromOpaque(value).takeUnretainedValue().floatValue
                    font.state = .downloading(progress)
                    DispatchQueue.main.async {
                        handler?(font)
                    }
                }
            case .didFinish:
                self.storeDownloadedFont(font)
                font.state = .didFinish(nil)
                DispatchQueue.main.async {
                    handler?(font)
                }
            case .didFailWithError:
                var error: NSError
                let key = Unmanaged.passRetained(kCTFontDescriptorMatchingError).autorelease().toOpaque()
                if let value = CFDictionaryGetValue(info, key) {
                    error = Unmanaged<NSError>.fromOpaque(value).takeUnretainedValue()
                } else {
                    error = NSError(domain: "com.whx.sfm", code: -1, userInfo: [NSLocalizedDescriptionKey: "Download fail with unknown error"])
                }
                font.state = .didFinish(error)
                DispatchQueue.main.async {
                    handler?(font)
                }
            default:
                break
            }
            return true
        }
    }
}
