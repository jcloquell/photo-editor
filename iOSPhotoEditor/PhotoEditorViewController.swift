//
//  ViewController.swift
//  Photo Editor
//
//  Created by Mohamed Hamed on 4/23/17.
//  Copyright © 2017 Mohamed Hamed. All rights reserved.
//

import UIKit

public enum LogoImage {
    case first
    case second
    case third
}

public enum NameCapitalization: String {
    case capitalized = "Aa"
    case uppercased = "AA"
    case lowercased = "aa"
}

public final class PhotoEditorViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var canvasView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var canvasImageView: UIImageView!
    
    @IBOutlet weak var bottomToolbar: UIView!
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var deleteView: UIView!
    @IBOutlet weak var colorsCollectionView: UICollectionView!
    @IBOutlet weak var colorPickerView: UIView!
    @IBOutlet weak var colorPickerViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var brandLogoSelectorView: UIView!
    @IBOutlet weak var firstLogoImageView: UIImageView!
    @IBOutlet weak var secondLogoImageView: UIImageView!
    @IBOutlet weak var thirdLogoImageView: UIImageView!
    @IBOutlet weak var triangleView: UIView!
    @IBOutlet weak var triangleViewLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var nameEditionView: UIView!
    @IBOutlet weak var namePickerView: UIPickerView!
    @IBOutlet weak var nameCapitalizationLabel: UILabel!
    @IBOutlet weak var nameColorView: UIView!
    
    @IBOutlet weak var stickerButton: UIButton!
    @IBOutlet weak var editionButton: UIButton!
    @IBOutlet weak var shopButton: UIButton!
    @IBOutlet weak var textButton: UIButton!
    @IBOutlet weak var cropButton: UIButton!
    @IBOutlet weak var drawButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    public var image: UIImage?
    public var stickers: [UIImage] = []
    public var colors: [UIColor] = []
    public var hiddenControls: [Control] = []
    let fonts: [UIFont?] = [.systemFont(ofSize: 24.0),
                            UIFont(name: "Noteworthy", size: 19),
                            UIFont(name: "Gelasio", size: 19),
                            UIFont(name: "Courier New", size: 19),
                            UIFont(name: "Futura", size: 19)]
    
    public var photoEditorDelegate: PhotoEditorDelegate?
    var colorsCollectionViewDelegate: ColorsCollectionViewDelegate!
    
    var stickersVCIsVisible = false
    var logoImage: LogoImage = .first
    var nameCapitalization: NameCapitalization = .capitalized
    var drawColor: UIColor = UIColor.black
    var textColor: UIColor = .darkText
    var isDrawing: Bool = false
    var lastPoint: CGPoint!
    var swiped = false
    var lastPanPoint: CGPoint?
    var lastTextViewTransform: CGAffineTransform?
    var lastTextViewTransCenter: CGPoint?
    var lastTextViewFont:UIFont?
    var activeTextView: UITextView?
    var imageViewToPan: UIImageView?
    
    var stickersViewController: StickersViewController!
    
    lazy var logoImageView: UIImageView = {
        let imageView = UIImageView(image: firstLogoImageView.image)
        imageView.contentMode = .scaleAspectFit
        imageView.frame.size = CGSize(width: 100, height: 100)
        imageView.center = canvasImageView.center
        canvasImageView.addSubview(imageView)
        addGestures(view: imageView)
        return imageView
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: canvasImageView.center.y,
                                          width: UIScreen.main.bounds.width, height: 30))
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOffset = CGSize(width: 1.0, height: 0.0)
        label.layer.shadowOpacity = 0.2
        label.layer.shadowRadius = 1.0
        label.layer.backgroundColor = UIColor.clear.cgColor
        label.textAlignment = .center
        canvasImageView.addSubview(label)
        addGestures(view: label)
        return label
    }()
    
    public override func loadView() {
        registerFont()
        super.loadView()
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setImageView(image: image!)
        
        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(screenEdgeSwiped))
        edgePan.edges = .bottom
        edgePan.delegate = self
        view.addGestureRecognizer(edgePan)
        
        configureCollectionView()
        stickersViewController = StickersViewController(nibName: "StickersViewController", bundle: Bundle(for: StickersViewController.self))
        hideControls()
        namePickerView.delegate = self
        namePickerView.dataSource = self
        nameColorView.layer.borderWidth = 1
        nameColorView.layer.borderColor = UIColor.darkText.cgColor
        backButton.setImage(UIImage(named: "icon_back_button"), for: .normal)
        editionButton.setImage(UIImage(named: "icon_photo_edition"), for: .normal)
        shopButton.setImage(UIImage(named: "icon_shopping_bag"), for: .normal)
    }
    
    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = view as? UILabel ?? UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.font = fonts[row]
        applyNameCapitalization(to: label, text: "Jorge Cloquell")
        namePickerView.subviews[1].backgroundColor = .clear //todo
        return label
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        updateNameLabel()
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return fonts.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "Jorge Cloquell"
    }
    
    public func setFirstLogo(pictureUrl: String) {
        firstLogoImageView.image = pictureUrl.toUIImage()
    }
    
    public func setSecondLogo(pictureUrl: String) {
        secondLogoImageView.image = pictureUrl.toUIImage()
    }
    
    public func setThirdLogo(pictureUrl: String) {
        thirdLogoImageView.image = pictureUrl.toUIImage()
    }
    
    func configureCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 30, height: 30)
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        colorsCollectionView.collectionViewLayout = layout
        colorsCollectionViewDelegate = ColorsCollectionViewDelegate()
        colorsCollectionViewDelegate.colorDelegate = self
        if !colors.isEmpty {
            colorsCollectionViewDelegate.colors = colors
        }
        colorsCollectionView.delegate = colorsCollectionViewDelegate
        colorsCollectionView.dataSource = colorsCollectionViewDelegate
        colorsCollectionView.register(
            UINib(nibName: "ColorCollectionViewCell", bundle: Bundle(for: ColorCollectionViewCell.self)),
            forCellWithReuseIdentifier: "ColorCollectionViewCell")
    }
    
    func setImageView(image: UIImage) {
        imageView.image = image
    }
    
    func hideToolbar(hide: Bool) {
        bottomToolbar.isHidden = hide
        if hide {
            brandLogoSelectorView.isHidden = true
            nameEditionView.isHidden = true
        } else if stickerButton.isSelected {
            brandLogoSelectorView.isHidden = false
        } else if textButton.isSelected {
            nameEditionView.isHidden = false
        }
    }
    
    func reloadNamePicker() {
        namePickerView.reloadAllComponents()
    }
    
    func applyNameCapitalization(to label: UILabel, text: String) {
        switch nameCapitalization {
        case .capitalized:
            label.text = text.capitalized
        case .uppercased:
            label.text = text.uppercased()
        case .lowercased:
            label.text = text.lowercased()
        }
    }
    
    func updateLogoImage() {
        switch logoImage {
        case .first:
            logoImageView.image = firstLogoImageView.image
        case .second:
            logoImageView.image = secondLogoImageView.image
        case .third:
            logoImageView.image = thirdLogoImageView.image
        }
    }
    
    func updateNameLabel() {
        nameLabel.textColor = textColor
        nameLabel.font = fonts[namePickerView.selectedRow(inComponent: 0)]
        applyNameCapitalization(to: nameLabel, text: "Jorge Cloquell")
    }
    
    func updateTriangleViewPosition(forSelectedView view: UIView) {
        triangleViewLeadingConstraint.constant = view.center.x - triangleView.frame.size.width / 2
    }
    
}

extension PhotoEditorViewController: ColorDelegate {
    
    func didSelectColor(color: UIColor) {
        if isDrawing {
            self.drawColor = color
        } else if activeTextView != nil {
            activeTextView?.textColor = color
            textColor = color
        }
    }
    
}

private extension String {
    
    func toUIImage() -> UIImage? {
        if let url = URL(string: self),
           let data = try? Data(contentsOf: url) {
            return UIImage(data: data)
        }
        return nil
    }
    
}
