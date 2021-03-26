//
//  ViewController.swift
//  Photo Editor
//
//  Created by Mohamed Hamed on 4/23/17.
//  Copyright © 2017 Mohamed Hamed. All rights reserved.
//

import UIKit

public final class PhotoEditorViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    /** holding the 2 imageViews original image and drawing & stickers */
    @IBOutlet weak var canvasView: UIView!
    //To hold the image
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    //To hold the drawings and stickers
    @IBOutlet weak var canvasImageView: UIImageView!
    
    @IBOutlet weak var topToolbar: UIView!
    @IBOutlet weak var bottomToolbar: UIView!
    
    @IBOutlet weak var topGradient: UIView!
    @IBOutlet weak var bottomGradient: UIView!
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var deleteView: UIView!
    @IBOutlet weak var colorsCollectionView: UICollectionView!
    @IBOutlet weak var colorPickerView: UIView!
    @IBOutlet weak var colorPickerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var namePickerView: UIPickerView!
    
    //Controls
    @IBOutlet weak var cropButton: UIButton!
    @IBOutlet weak var stickerButton: UIButton!
    @IBOutlet weak var drawButton: UIButton!
    @IBOutlet weak var textButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    public var image: UIImage?
    /**
     Array of Stickers -UIImage- that the user will choose from
     */
    public var stickers : [UIImage] = []
    /**
     Array of Colors that will show while drawing or typing
     */
    public var colors  : [UIColor] = []
    
    public var photoEditorDelegate: PhotoEditorDelegate?
    var colorsCollectionViewDelegate: ColorsCollectionViewDelegate!
    
    // list of controls to be hidden
    public var hiddenControls : [control] = []
    
    var stickersVCIsVisible = false
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
    
    //Register Custom font before we load XIB
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
        backButton.setImage(UIImage(named: "icon_back_button"), for: .normal)
    }
    
    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = view as? UILabel ?? UILabel()
        label.textColor = .black
        label.textAlignment = .center
        if row == 0 {
            label.font = UIFont.systemFont(ofSize: 24.0)
        } else {
            label.font = UIFont(name:"Noteworthy", size:19)
        }
        label.text = "Jorge Cloquell"
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
        return 2
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
        //let size = image.suitableSize(widthLimit: UIScreen.main.bounds.width)
        //imageViewHeightConstraint.constant = (size?.height)!
    }
    
    func hideToolbar(hide: Bool) {
        //topToolbar.isHidden = hide
        //topGradient.isHidden = hide
        bottomToolbar.isHidden = hide
        //bottomGradient.isHidden = hide
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
