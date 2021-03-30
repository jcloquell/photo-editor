//
//  ViewController.swift
//  Photo Editor
//
//  Created by Mohamed Hamed on 4/23/17.
//  Copyright © 2017 Mohamed Hamed. All rights reserved.
//

import UIKit

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
    
    @IBOutlet weak var nameEditionView: UIView!
    @IBOutlet weak var namePickerView: UIPickerView!
    @IBOutlet weak var nameCapitalizationLabel: UILabel!
    @IBOutlet weak var nameColorView: UIView!
    
    @IBOutlet weak var cropButton: UIButton!
    @IBOutlet weak var stickerButton: UIButton!
    @IBOutlet weak var drawButton: UIButton!
    @IBOutlet weak var textButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    public var image: UIImage?
    public var stickers: [UIImage] = []
    public var colors: [UIColor] = []
    public var hiddenControls: [Control] = []
    let fonts: [UIFont?] = [UIFont.systemFont(ofSize: 24.0),
                            UIFont(name:"Noteworthy", size:19),
                            UIFont(name:"Gelasio", size:19),
                            UIFont(name:"Courier New", size:19),
                            UIFont(name:"Futura", size:19)]
    
    public var photoEditorDelegate: PhotoEditorDelegate?
    var colorsCollectionViewDelegate: ColorsCollectionViewDelegate!
    
    var stickersVCIsVisible = false
    var nameCapitalization: NameCapitalization = .capitalized
    var drawColor: UIColor = UIColor.black
    var textColor: UIColor = UIColor.white
    var isDrawing: Bool = false
    var lastPoint: CGPoint!
    var swiped = false
    var lastPanPoint: CGPoint?
    var lastTextViewTransform: CGAffineTransform?
    var lastTextViewTransCenter: CGPoint?
    var lastTextViewFont:UIFont?
    var activeTextView: UITextView?
    var imageViewToPan: UIImageView?
    var isTyping: Bool = false
    
    var stickersViewController: StickersViewController!
    
    public override func loadView() {
        registerFont()
        super.loadView()
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.setImageView(image: image!)
        
        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(screenEdgeSwiped))
        edgePan.edges = .bottom
        edgePan.delegate = self
        self.view.addGestureRecognizer(edgePan)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow),
                                               name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(keyboardWillChangeFrame(_:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        
        configureCollectionView()
        stickersViewController = StickersViewController(nibName: "StickersViewController", bundle: Bundle(for: StickersViewController.self))
        hideControls()
        namePickerView.delegate = self
        namePickerView.dataSource = self
        nameColorView.layer.borderWidth = 1
        nameColorView.layer.borderColor = UIColor.darkText.cgColor
        backButton.setImage(UIImage(named: "icon_back_button"), for: .normal)
    }
    
    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = view as? UILabel ?? UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.font = fonts[row]
        let text = "Jorge Cloquell"
        switch nameCapitalization {
        case .capitalized:
            label.text = text.capitalized
        case .uppercased:
            label.text = text.uppercased()
        case .lowercased:
            label.text = text.lowercased()
        }
        namePickerView.subviews[1].backgroundColor = .clear //todo
        return label
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //todo
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
    }
    
    func reloadNamePicker() {
        namePickerView.reloadAllComponents()
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
