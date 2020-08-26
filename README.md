# SystemFontManager
一个简单的下载系统字体工具类

### 字体类数据结构

由于每个字体包括多个字体集，所以设计数据结构如下：

```
class SystemFont {
    
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
    
    init(displayName: String, fontNames: [FontName]) {
        self.displayName = displayName
        self.fontNames = fontNames
    }
}
```

### 下载字体

使用`CTFontDescriptorMatchFontDescriptorsWithProgressHandler`下载系统字体

代码如下：

```
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
```

### 一个小坑

在下载后重新运行App，字体没失效，这里这里的解决办法是，将已下载的字体做一个标记，在重新运行App时，再次download一遍，这时候不需要再次去网络上下载字体，实际是直接从手机系统缓存中获取的。代码如下：

```
    private var downloadedFonts: [String] {
        set {
            UserDefaults.standard.set(newValue, forKey: downloadedFontsKey)
        }
        get {
            UserDefaults.standard.array(forKey: downloadedFontsKey) as? [String] ?? ["苹方"]
        }
    }
    
    private func storeDownloadedFont(_ font: SystemFont) {
        if !downloadedFonts.contains(font.displayName) {
            downloadedFonts.append(font.displayName)
        }
    }
```

### 使用示例

在App启动时调用`initFonts`， 完整示例代码如下：

```

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

```

更具体的细节，请下载[Demo](https://github.com/hxwxww/SystemFontManager)查看。