//
//  SystemFont.swift
//  SystemFontManager
//
//  Created by HongXiangWen on 2020/8/25.
//  Copyright © 2020 WHX. All rights reserved.
//

import UIKit

class SystemFont {
    
    enum State {
        case none
        case didBegin
        case downloading(Float)
        case didFinish(Error?)
    }
    
    struct FontName {
        
        enum Style {
            case regular
            case light
            case bold
            case black
            
            var displayName: String {
                switch self {
                case .regular:
                    return "常规体"
                case .light:
                    return "细体"
                case .bold:
                    return "粗体"
                case .black:
                    return "黑体"
                }
            }
        }
        
        let style: Style
        let fontName: String
    }
    
    let displayName: String
    let fontNames: [FontName]
    
    var state: State = .none
    
    var isDownloaded: Bool {
        switch state {
        case .didFinish(let error):
            return error == nil
        default:
            return false
        }
    }
    
    var isFinished: Bool {
        switch state {
        case .didFinish(_):
            return true
        default:
            return false
        }
    }
    
    init(displayName: String, fontNames: [FontName]) {
        self.displayName = displayName
        self.fontNames = fontNames
    }
}

extension SystemFont {
    
    static func loadFonts() -> [SystemFont] {
        let fonts = [
            SystemFont(displayName: "苹方", fontNames: [
                FontName(style: .regular, fontName: "PingFangSC-Regular"),
                FontName(style: .light, fontName: "PingFangSC-Light"),
                FontName(style: .bold, fontName: "PingFangSC-Semibold")
            ]),
            SystemFont(displayName: "宋体", fontNames: [
                FontName(style: .regular, fontName: "STSongti-SC-Regular"),
                FontName(style: .light, fontName: "STSongti-SC-Light"),
                FontName(style: .bold, fontName: "STSongti-SC-Bold"),
                FontName(style: .black, fontName: "STSongti-SC-Black")
            ]),
            SystemFont(displayName: "华文仿宋", fontNames: [
                FontName(style: .regular, fontName: "STFangsong")
            ]),
            SystemFont(displayName: "楷体", fontNames: [
                FontName(style: .regular, fontName: "STKaitiSC-Regular"),
                FontName(style: .bold, fontName: "STKaitiSC-Bold"),
                FontName(style: .black, fontName: "STKaitiSC-Black")
            ]),
            SystemFont(displayName: "行楷", fontNames: [
                FontName(style: .light, fontName: "STXingkaiSC-Light"),
                FontName(style: .bold, fontName: "STXingkaiSC-Bold")
            ]),
            SystemFont(displayName: "报隶", fontNames: [
                FontName(style: .regular, fontName: "STBaoliSC-Regular")
            ]),
            SystemFont(displayName: "隶变", fontNames: [
                FontName(style: .regular, fontName: "STLibianSC-Regular")
            ]),
            SystemFont(displayName: "兰亭黑", fontNames: [
                FontName(style: .regular, fontName: "FZLTZHK--GBK1-0"),
                FontName(style: .light, fontName: "FZLTXHK--GBK1-0"),
                FontName(style: .black, fontName: "FZLTTHK--GBK1-0")
            ]),
            SystemFont(displayName: "娃娃体", fontNames: [
                FontName(style: .regular, fontName: "DFWaWaSC-W5")
            ]),
            SystemFont(displayName: "雅痞", fontNames: [
                FontName(style: .regular, fontName: "YuppySC-Regular")
            ]),
            SystemFont(displayName: "魏碑", fontNames: [
                FontName(style: .bold, fontName: "WeibeiSC-Bold")
            ]),
            SystemFont(displayName: "翩翩体", fontNames: [
                FontName(style: .regular, fontName: "HanziPenSC-W3"),
                FontName(style: .bold, fontName: "HanziPenSC-W5")
            ]),
            SystemFont(displayName: "圆体", fontNames: [
                FontName(style: .regular, fontName: "STYuanti-SC-Regular"),
                FontName(style: .light, fontName: "STYuanti-SC-Light"),
                FontName(style: .black, fontName: "STYuanti-SC-Bold")
            ]),
            SystemFont(displayName: "手札体", fontNames: [
                FontName(style: .regular, fontName: "HannotateSC-W5"),
                FontName(style: .bold, fontName: "HannotateSC-W7")
            ]),
        ]
        return fonts
    }
}
