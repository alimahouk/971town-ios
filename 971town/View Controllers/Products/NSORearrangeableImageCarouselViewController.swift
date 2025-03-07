//
//  NSORearrangeableImageCarouselViewController.swift
//  971town
//
//  Created by Ali Mahouk on 25/03/2023.
//

import API
import SDWebImage
import UIKit
import UniformTypeIdentifiers


class ImageCollectionViewCell: UICollectionViewCell {
        internal class DeleteButton: UIButton {
                override init(frame: CGRect) {
                        var deleteButtonConfig = UIButton.Configuration.plain()
                        deleteButtonConfig.image = UIImage(systemName: "minus",
                                                           withConfiguration: UIImage.SymbolConfiguration(font: .boldSystemFont(ofSize: 12.0)))?.withRenderingMode(.alwaysTemplate)
                        
                        super.init(frame: frame)
                        self.configuration = deleteButtonConfig
                        self.layer.cornerRadius = self.bounds.width / 2
                        self.layer.masksToBounds = true
                        self.tintColor = .systemGray
                        
                        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .light))
                        blur.frame = self.bounds
                        blur.isUserInteractionEnabled = false // This allows touches to forward to the button.
                        self.insertSubview(blur,
                                           at: 0)
                }
                
                required init?(coder: NSCoder) {
                        fatalError("init(coder:) has not been implemented")
                }
                
                override func point(inside point: CGPoint,
                                    with event: UIEvent?) -> Bool {
                        return bounds.insetBy(dx: -20,
                                              dy: -20).contains(point)
                }
        }
        
        
        private let cornerRadius: CGFloat = UISegmentedControl().layer.cornerRadius
        
        public let addMediaButton: UIButton
        public let deleteButton: DeleteButton
        public let imageView: UIImageView
        public let imageViewContainer: UIView
        public var showsAddMediaButton: Bool = false {
                didSet {
                        self.addMediaButton.isHidden = !self.showsAddMediaButton
                }
        }
        public var showsDeleteButton: Bool = true {
                didSet {
                        self.attributionView.isHidden = !self.showsDeleteButton
                        self.attributionTextField.isHidden = !self.showsDeleteButton
                        self.deleteButton.isHidden = !self.showsDeleteButton
                        self.imageViewContainer.isHidden = !self.showsDeleteButton
                }
        }
        public let attributionHeadingLabel: UILabel
        public let attributionLabel: UILabel
        public let attributionTextField: UITextField
        public let attributionView: UIStackView
        
        
        override init(frame: CGRect) {
                var addMediaButtonConfig = UIButton.Configuration.plain()
                addMediaButtonConfig.baseBackgroundColor = .black
                addMediaButtonConfig.contentInsets = NSDirectionalEdgeInsets(
                        top: 40,
                        leading: 40,
                        bottom: 40,
                        trailing: 40
                )
                addMediaButtonConfig.image = UIImage(systemName: "plus.circle",
                                                     withConfiguration: UIImage.SymbolConfiguration(pointSize: 64, weight: .thin))
                addMediaButtonConfig.imagePadding = 20
                addMediaButtonConfig.imagePlacement = .top
                addMediaButtonConfig.title = "Add Media"
                
                let pasteboard = UIPasteboard.general
                
                if pasteboard.hasImages, pasteboard.image != nil {
                        addMediaButtonConfig.titlePadding = 20
                        
                        var subtitleContainer = AttributeContainer()
                        subtitleContainer.foregroundColor = .systemGray
                        addMediaButtonConfig.attributedSubtitle = AttributedString("If you copied an image, double-tap here to paste it.",
                                                                                   attributes: subtitleContainer)
                }
                
                self.addMediaButton = UIButton(type: .system)
                self.addMediaButton.backgroundColor = .init(white: 1.0,
                                                            alpha: 0.8)
                self.addMediaButton.configuration = addMediaButtonConfig
                self.addMediaButton.frame = CGRect(
                        x: 12.5,
                        y: 12.5,
                        width: frame.width - (12.5 * 2),
                        height: frame.width - (12.5 * 2)
                )
                self.addMediaButton.layer.cornerRadius = self.cornerRadius
                self.addMediaButton.layer.masksToBounds = true
                self.addMediaButton.layer.name = "addMediaButton"
                
                let attributionIconView = UIImageView(
                        image: UIImage(systemName: "info.bubble")?.withTintColor(.systemGray,
                                                                                 renderingMode: .alwaysOriginal)
                )
                attributionIconView.contentMode = .center
                attributionIconView.frame = CGRect(
                        x: 0,
                        y: 0,
                        width: 35,
                        height: 18
                )
                let attributionIconContainer = UIView(frame: attributionIconView.bounds)
                attributionIconContainer.addSubview(attributionIconView)
                
                self.attributionHeadingLabel = UILabel()
                self.attributionHeadingLabel.font = .boldSystemFont(ofSize: UIFont.systemFontSize)
                self.attributionHeadingLabel.text = "ATTRIBUTION"
                self.attributionHeadingLabel.textColor = .systemGray
                self.attributionHeadingLabel.setContentHuggingPriority(.defaultHigh,
                                                                       for: .vertical)
                
                self.attributionLabel = UILabel()
                self.attributionLabel.font = .systemFont(ofSize: 18)
                self.attributionLabel.numberOfLines = 0
                self.attributionLabel.setContentHuggingPriority(.defaultLow,
                                                                for: .vertical)
                
                self.attributionTextField = UITextField()
                self.attributionTextField.backgroundColor = .init(white: 1.0,
                                                                  alpha: 0.8)
                self.attributionTextField.clearButtonMode = .always
                self.attributionTextField.font = .systemFont(ofSize: 18)
                self.attributionTextField.layer.cornerRadius = self.cornerRadius
                self.attributionTextField.layer.masksToBounds = true
                self.attributionTextField.layer.shadowRadius = 10
                self.attributionTextField.layer.shadowOpacity = 0.3
                self.attributionTextField.layer.shadowColor = UIColor.black.cgColor
                self.attributionTextField.layer.shadowOffset = .zero
                self.attributionTextField.leftView = attributionIconContainer
                self.attributionTextField.leftViewMode = .always
                self.attributionTextField.placeholder = "Attribution"
                self.attributionTextField.returnKeyType = .done
                self.attributionTextField.translatesAutoresizingMaskIntoConstraints = false
                
                self.attributionView = UIStackView()
                self.attributionView.alignment = .leading
                self.attributionView.axis = .vertical
                self.attributionView.translatesAutoresizingMaskIntoConstraints = false
                
                self.deleteButton = DeleteButton(
                        frame: CGRect(
                                x: 0,
                                y: 0,
                                width: 25,
                                height: 25
                        )
                )
                self.deleteButton.layer.name = "deleteButton"
                
                self.imageViewContainer = UIView()
                self.imageViewContainer.layer.masksToBounds = false
                self.imageViewContainer.layer.shadowRadius = 14
                self.imageViewContainer.layer.shadowOpacity = 0.4
                self.imageViewContainer.layer.shadowColor = UIColor.black.cgColor
                self.imageViewContainer.layer.shadowOffset = .zero
                self.imageViewContainer.translatesAutoresizingMaskIntoConstraints = false
                
                self.imageView = UIImageView()
                self.imageView.contentMode = .scaleAspectFill
                self.imageView.frame = imageViewContainer.bounds
                self.imageView.layer.cornerRadius = self.cornerRadius
                self.imageView.layer.masksToBounds = true
                self.imageView.translatesAutoresizingMaskIntoConstraints = false
                
                super.init(frame: frame)
                self.backgroundColor = .clear
                
                self.attributionView.addArrangedSubview(self.attributionHeadingLabel)
                self.attributionView.addArrangedSubview(self.attributionLabel)
                
                self.imageViewContainer.addSubview(self.imageView)
                
                let imageViewContainerViews = [
                        "imageView": imageView
                ] as [String : Any]
                var imageViewConstraints = NSLayoutConstraint.constraints(
                        withVisualFormat: "V:|[imageView]|",
                        options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                        metrics: nil,
                        views: imageViewContainerViews
                )
                imageViewConstraints += NSLayoutConstraint.constraints(
                        withVisualFormat: "H:|[imageView]|",
                        options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                        metrics: nil,
                        views: imageViewContainerViews
                )
                self.imageViewContainer.addConstraints(imageViewConstraints)
                
                self.contentView.addSubview(self.addMediaButton)
                self.contentView.addSubview(self.attributionView)
                self.contentView.addSubview(self.attributionTextField)
                self.contentView.addSubview(self.imageViewContainer)
                self.contentView.addSubview(self.deleteButton)
        }
        
        required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
        }
}

class NSORearrangeableImageCarouselViewController: UIViewController {
        private var addMediaButton: UIButton? {
                get {
                        var ret: UIButton?
                        
                        if let addMediaCell = self.collectionView.cellForItem(at: IndexPath(item: self.editedMedia.count, section: 0)) {
                                for subview in addMediaCell.contentView.subviews {
                                        if let button = subview as? UIButton, button.layer.name == "addMediaButton" {
                                                ret = button
                                                
                                                break
                                        }
                                }
                        }
                        
                        return ret
                }
        }
        private var cancelButton: UIBarButtonItem?
        private let collectionView: UICollectionView
        private static let collectionViewCellIdentifier: String = "ImageCollectionViewCell"
        private var currentScrollOffset: CGPoint?
        private let cellPeekWidth: CGFloat = 20
        private let cellSpacing: CGFloat = 20
        private var doneButton: UIBarButtonItem?
        private let progressIndicator: UIAlertController
        private let scrollThreshold: CGFloat = 40
        private var shouldUpdateMedia: Bool = false
        private var viewIsLoaded: Bool = false
        
        public var editedMedia: [NSOProductMedium] = []
        public var media: [NSOProductMedium] = []
        public var product: NSOProduct
        
        
        init(product: NSOProduct) {
                self.media = product.media
                self.editedMedia = [NSOProductMedium](product.media.map { $0.copy() } as! [NSOProductMedium])
                self.product = product
                
                let activityIndicatorView = UIActivityIndicatorView()
                activityIndicatorView.hidesWhenStopped = true
                activityIndicatorView.isUserInteractionEnabled = false
                activityIndicatorView.startAnimating()
                activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
                
                self.progressIndicator = UIAlertController(
                        title: "Loading…",
                        message: nil,
                        preferredStyle: .alert
                )
                self.progressIndicator.view.addSubview(activityIndicatorView)
                
                let layout = UICollectionViewFlowLayout()
                layout.scrollDirection = .horizontal
                
                self.collectionView = UICollectionView(frame: .zero,
                                                       collectionViewLayout: layout)
                
                super.init(nibName: nil,
                           bundle: nil)
                self.title = "Product Media"
                
                self.collectionView.backgroundColor = .clear
                self.collectionView.dataSource = self
                self.collectionView.decelerationRate = .fast
                self.collectionView.delegate = self
                self.collectionView.isPagingEnabled = false
                self.collectionView.keyboardDismissMode = .interactive
                self.collectionView.showsHorizontalScrollIndicator = false
                self.collectionView.showsVerticalScrollIndicator = false
                self.collectionView.register(ImageCollectionViewCell.self,
                                             forCellWithReuseIdentifier: NSORearrangeableImageCarouselViewController.collectionViewCellIdentifier)
                
                let longPressGesture = UILongPressGestureRecognizer(
                        target: self,
                        action: #selector(self.handleLongPress)
                )
                self.collectionView.addGestureRecognizer(longPressGesture)
                
                NotificationCenter.default.addObserver(
                        self,
                        selector: #selector(self.appWillEnterForeground),
                        name: UIApplication.willEnterForegroundNotification,
                        object: nil
                )
                NotificationCenter.default.addObserver(
                        self,
                        selector: #selector(keyboardWillShow),
                        name: UIResponder.keyboardWillShowNotification,
                        object: nil
                )
                NotificationCenter.default.addObserver(
                        self,
                        selector: #selector(keyboardWillHide),
                        name: UIResponder.keyboardWillHideNotification,
                        object: nil
                )
                
                let progressIndicatorViews = [
                        "activityIndicatorView": activityIndicatorView
                ]
                var progressIndicatorConstraints = NSLayoutConstraint.constraints(
                        withVisualFormat: "V:|-(20)-[activityIndicatorView]-(20)-|",
                        options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                        metrics: nil,
                        views: progressIndicatorViews
                )
                progressIndicatorConstraints += NSLayoutConstraint.constraints(
                        withVisualFormat: "H:|-(20)-[activityIndicatorView]",
                        options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                        metrics: nil,
                        views: progressIndicatorViews
                )
                self.progressIndicator.view.addConstraints(progressIndicatorConstraints)
        }
        
        required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
        }
        
        deinit {
                NotificationCenter.default.removeObserver(self)
        }
        
        private func addImage(_ image: UIImage,
                              attribution: String?,
                              animated: Bool) {
                let medium = NSOProductMedium(
                        attribution: attribution,
                        image: image,
                        index: self.editedMedia.count,
                        mediaFormat: .jpg,
                        mediaMode: .light,
                        mediaType: .image
                )
                self.editedMedia.append(medium)
                self.enableFormButtons()
                
                let indexPath = IndexPath(item: self.editedMedia.count - 1,
                                          section: 0)
                
                if self.editedMedia.count < NSOAPI.Configuration.productMediaFileCountLimit {
                        self.collectionView.insertItems(at: [indexPath])
                        self.collectionView.scrollToItem(at: indexPath,
                                                         at: .centeredHorizontally,
                                                         animated: animated)
                } else {
                        self.collectionView.reloadItems(at: [indexPath])
                }
        }
        
        @objc
        private dynamic func appWillEnterForeground() {
                if let addMediaButton = self.addMediaButton {
                        let pasteboard = UIPasteboard.general
                        
                        if pasteboard.hasImages, pasteboard.image != nil {
                                var addMediaButtonConfig = addMediaButton.configuration
                                addMediaButtonConfig?.titlePadding = 20
                                
                                var subtitleContainer = AttributeContainer()
                                subtitleContainer.foregroundColor = .systemGray
                                addMediaButtonConfig?.attributedSubtitle = AttributedString("If you copied an image, double-tap here to paste it.",
                                                                                            attributes: subtitleContainer)
                                addMediaButton.configuration = addMediaButtonConfig
                        }
                }
        }
        
        @objc
        private dynamic func dismissView() {
                if self.shouldUpdateMedia {
                        let confirmationAlert = UIAlertController(
                                title: "Discard Changes?",
                                message: "Any edits you made will be lost.",
                                preferredStyle: .alert
                        )
                        confirmationAlert.addAction(
                                UIAlertAction(
                                        title: "Discard",
                                        style: .destructive,
                                        handler: { action in
                                                self.navigationController?.dismiss(animated: true)
                                        }
                                )
                        )
                        confirmationAlert.addAction(
                                UIAlertAction(title: "Back",
                                              style: .cancel)
                        )
                        self.navigationController?.present(confirmationAlert,
                                                           animated: true)
                } else {
                        self.navigationController?.dismiss(animated: true)
                }
        }
        
        private func enableFormButtons() {
                self.shouldUpdateMedia = false
                
                for original in self.media {
                        var exists = false
                        
                        for edited in self.editedMedia {
                                if original == edited {
                                        if original.index != edited.index ||
                                                original.attribution != edited.attribution {
                                                self.shouldUpdateMedia = true
                                        }
                                        
                                        exists = true
                                        
                                        break
                                }
                        }
                        
                        if !exists {
                                self.shouldUpdateMedia = true
                        }
                }
                
                if !self.shouldUpdateMedia {
                        for edited in self.editedMedia {
                                var exists = false
                                
                                for original in self.media {
                                        if original == edited {
                                                exists = true
                                                
                                                break
                                        }
                                }
                                
                                if !exists {
                                        self.shouldUpdateMedia = true
                                }
                        }
                }
                
                self.doneButton?.isEnabled = self.shouldUpdateMedia
        }
        
        @objc
        private dynamic func handleLongPress(gesture: UILongPressGestureRecognizer) {
                switch gesture.state {
                case .began:
                        guard let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: self.collectionView)) else {
                                break
                        }
                        self.collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
                case .changed:
                        self.collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
                case .ended:
                        self.collectionView.endInteractiveMovement()
                default:
                        self.collectionView.cancelInteractiveMovement()
                }
        }
        
        @objc
        private dynamic func keyboardWillHide(notification: NSNotification){
                self.collectionView.contentInset = .zero
                self.collectionView.scrollIndicatorInsets = .zero
        }
        
        @objc
        private dynamic func keyboardWillShow(notification: NSNotification)
        {
                let info = notification.userInfo!
                let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
                let contentInsets = UIEdgeInsets(
                        top: 0,
                        left: 0,
                        bottom: keyboardSize!.height,
                        right: 0
                )
                self.collectionView.contentInset = contentInsets
                self.collectionView.scrollIndicatorInsets = contentInsets
        }
        
        @objc
        private dynamic func pasteMedia() {
                let pasteboard = UIPasteboard.general
                
                if pasteboard.hasImages, let image = pasteboard.image {
                        self.addImage(image,
                                      attribution: nil,
                                      animated: true)
                }
        }
        
        @objc
        private dynamic func presentCamera() {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        let pickerController = UIImagePickerController()
                        pickerController.allowsEditing = true
                        pickerController.delegate = self
                        pickerController.sourceType = .camera
                        self.navigationController?.present(pickerController,
                                                           animated: true)
                }
        }
        
        @objc
        private dynamic func presentMediaLibrary() {
                if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                        let pickerController = UIImagePickerController()
                        pickerController.allowsEditing = true
                        pickerController.delegate = self
                        pickerController.sourceType = .photoLibrary
                        self.navigationController?.present(pickerController,
                                                           animated: true)
                }
        }
        
        @objc
        private dynamic func presentMediaSourceSelectionSheet() {
                if UIImagePickerController.isSourceTypeAvailable(.camera)
                        && UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                        let alert = UIAlertController(
                                title: "Media Source",
                                message: nil,
                                preferredStyle: .actionSheet
                        )
                        alert.addAction(
                                UIAlertAction(
                                        title: "Camera",
                                        style: .default,
                                        handler: { action in
                                                self.presentCamera()
                                        }
                                )
                        )
                        alert.addAction(
                                UIAlertAction(
                                        title: "Photo Library",
                                        style: .default,
                                        handler: { action in
                                                self.presentMediaLibrary()
                                        }
                                )
                        )
                        alert.addAction(
                                UIAlertAction(
                                        title: "Cancel",
                                        style: .cancel
                                )
                        )
                        self.navigationController?.present(alert,
                                                           animated: true)
                } else if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                        // Skip the sheet and present the library directly.
                        self.presentMediaLibrary()
                }
        }
        
        @objc
        private dynamic func textFieldDidChange(_ textfield: UITextField) {
                var attribution = textfield.text
                
                if attribution != nil {
                        attribution = attribution?.trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        if attribution!.isEmpty {
                                attribution = nil
                        }
                }
                
                if let cell = textfield.superview?.superview as? ImageCollectionViewCell {
                        if let indexPath = self.collectionView.indexPath(for: cell) {
                                let medium = self.editedMedia[indexPath.item]
                                medium.attribution = attribution
                                
                                self.enableFormButtons()
                        }
                }
        }
        
        @objc
        private dynamic func updateMedia() {
                self.doneButton?.isEnabled = false
                
                self.navigationController?.present(
                        self.progressIndicator,
                        animated: true,
                        completion: {
                                if self.shouldUpdateMedia {
                                        var images = [String : UIImage]()
                                        var metadata = [String : Any]()
                                        
                                        for edited in self.editedMedia {
                                                var exists = false
                                                
                                                for medium in self.media {
                                                        if edited.id == medium.id {
                                                                exists = true
                                                                
                                                                break
                                                        }
                                                }
                                                
                                                if !exists {
                                                        images[edited.fileHash!] = edited.image!
                                                }
                                                
                                                var medium_metadata = [
                                                        NSOProtocolKey.mediaType.rawValue: edited.mediaType!.rawValue,
                                                        NSOProtocolKey.index.rawValue: edited.index!
                                                ] as [String : Any]
                                                
                                                if let attribution = edited.attribution {
                                                        medium_metadata[NSOProtocolKey.attribution.rawValue] = attribution
                                                }
                                                
                                                if let id = edited.id {
                                                        medium_metadata[NSOProtocolKey.id.rawValue] = id
                                                }
                                                
                                                metadata[edited.fileHash!] = medium_metadata
                                        }
                                        
                                        let request = NSOUpdateProductMediaRequest(
                                                media: images,
                                                metadata: metadata,
                                                mediaMode: .light,
                                                productID: self.product.id!
                                        )
                                        NSOAPI.shared.updateProductMedia(
                                                request: request,
                                                responseHandler: { apiResponse, errorResponse, networkError in
                                                        if let networkError = networkError {
                                                                print(networkError)
                                                                
                                                                DispatchQueue.main.async {
                                                                        self.progressIndicator.dismiss(animated: true,
                                                                                                       completion: {
                                                                                let alert = UIAlertController(
                                                                                        title: "Network Issues",
                                                                                        message: "An error occurred. Try again later?",
                                                                                        preferredStyle: .alert
                                                                                )
                                                                                alert.addAction(
                                                                                        UIAlertAction(
                                                                                                title: ":(",
                                                                                                style: .default
                                                                                        )
                                                                                )
                                                                                self.navigationController?.present(alert,
                                                                                                                   animated: true)
                                                                                self.enableFormButtons()
                                                                        })
                                                                }
                                                        } else if let errorResponse = errorResponse {
                                                                DispatchQueue.main.async {
                                                                        self.progressIndicator.dismiss(animated: true,
                                                                                                       completion: {
                                                                                let alert = UIAlertController(
                                                                                        title: "",
                                                                                        message: errorResponse.error.errorMessage,
                                                                                        preferredStyle: .alert
                                                                                )
                                                                                alert.addAction(
                                                                                        UIAlertAction(
                                                                                                title: "Oh, No!",
                                                                                                style: .default
                                                                                        )
                                                                                )
                                                                                self.navigationController?.present(alert,
                                                                                                                   animated: true)
                                                                                self.enableFormButtons()
                                                                        })
                                                                }
                                                        } else if apiResponse != nil {
                                                                DispatchQueue.main.async {
                                                                        self.progressIndicator.dismiss(animated: false)
                                                                        self.navigationController?.dismiss(animated: true)
                                                                }
                                                        }
                                                }
                                        )
                                } else {
                                        self.progressIndicator.dismiss(animated: false)
                                        self.navigationController?.dismiss(animated: true)
                                }
                        }
                )
        }
        
        @objc
        private dynamic func userTappedDeleteButton(_ button: UIButton) {
                let confirmationAlert = UIAlertController(
                        title: "Delete Image",
                        message: "Are you sure you want to remove this image?",
                        preferredStyle: .alert
                )
                confirmationAlert.addAction(
                        UIAlertAction(
                                title: "Delete",
                                style: .destructive,
                                handler: { action in
                                        if let cell = button.superview?.superview as? ImageCollectionViewCell {
                                                if let indexPath = self.collectionView.indexPath(for: cell) {
                                                        self.editedMedia.remove(at: indexPath.item)
                                                        self.collectionView.deleteItems(at: [indexPath])
                                                        self.enableFormButtons()
                                                }
                                        }
                                }
                        )
                )
                confirmationAlert.addAction(
                        UIAlertAction(title: "Cancel",
                                      style: .cancel)
                )
                self.navigationController?.present(confirmationAlert,
                                                   animated: true)
        }
        
        override func viewDidLayoutSubviews() {
                super.viewDidLayoutSubviews()
                
                if self.cancelButton == nil {
                        self.cancelButton = UIBarButtonItem(
                                barButtonSystemItem: .close,
                                target: self,
                                action: #selector(self.dismissView)
                        )
                        self.navigationController?.navigationBar.topItem?.leftBarButtonItem = self.cancelButton
                }
                
                if self.doneButton == nil {
                        self.doneButton = UIBarButtonItem(
                                title: "Done",
                                style: .done,
                                target: self,
                                action: #selector(self.updateMedia)
                        )
                        self.doneButton?.isEnabled = false
                        self.navigationController?.navigationBar.topItem?.rightBarButtonItem = self.doneButton
                }
                
                self.collectionView.frame = self.view.bounds
        }
        
        override func viewDidLoad() {
                super.viewDidLoad()
                
                let blurEffect = UIBlurEffect(style: .light)
                let blurEffectView = UIVisualEffectView(effect: blurEffect)
                blurEffectView.frame.size = self.view.bounds.size
                
                self.view.addSubview(blurEffectView)
                self.view.addSubview(self.collectionView)
        }
        
        override func viewWillAppear(_ animated: Bool) {
                super.viewWillAppear(animated)
                
                if !self.viewIsLoaded {
                        if !self.editedMedia.isEmpty {
                                // Block until the first image loads.
                                self.navigationController?.present(
                                        self.progressIndicator,
                                        animated: true,
                                        completion: {
                                                for (index, medium) in self.editedMedia.enumerated() {
                                                        SDWebImageManager.shared.loadImage(
                                                                with: medium.fileURL,
                                                                options: .continueInBackground,
                                                                progress: nil,
                                                                completed: { [weak self] (image, data, error, cacheType, finished, url) in
                                                                        guard self != nil else { return }
                                                                        
                                                                        if let error = error {
                                                                                print(error)
                                                                                
                                                                                return
                                                                        }
                                                                        
                                                                        guard let image = image else { return }
                                                                        medium.image = image
                                                                        
                                                                        if index == 0 {
                                                                                self!.progressIndicator.dismiss(animated: true)
                                                                        }
                                                                }
                                                        )
                                                }
                                        }
                                )
                        }
                        
                        self.viewIsLoaded = true
                }
        }
}


// MARK: - UIAdaptivePresentationControllerDelegate

extension NSORearrangeableImageCarouselViewController: UIAdaptivePresentationControllerDelegate {
        func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
                var ret = true
                
                if self.shouldUpdateMedia {
                        ret = false
                }
                
                return ret
        }
        
        func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
                let generator = UINotificationFeedbackGenerator()
                generator.prepare()
                self.dismissView()
                generator.notificationOccurred(.warning)
        }
}


// MARK: - UICollectionViewDataSource

extension NSORearrangeableImageCarouselViewController: UICollectionViewDataSource {
        func collectionView(_ collectionView: UICollectionView,
                            cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSORearrangeableImageCarouselViewController.collectionViewCellIdentifier,
                                                              for: indexPath) as! ImageCollectionViewCell
                
                if indexPath.item < self.editedMedia.count {
                        let medium = self.editedMedia[indexPath.item]
                        
                        cell.addMediaButton.gestureRecognizers?.removeAll()
                        cell.showsAddMediaButton = false
                        cell.showsDeleteButton = true
                        
                        if medium.creatorID == NSOAPI.shared.currentUserAccount!.id
                                || medium.id == nil {
                                cell.attributionView.isHidden = true
                                
                                cell.attributionTextField.delegate = self
                                cell.attributionTextField.isHidden = false
                                cell.attributionTextField.text = medium.attribution
                                cell.attributionTextField.addTarget(
                                        self,
                                        action: #selector(self.textFieldDidChange),
                                        for: .editingChanged
                                )
                        } else {
                                cell.attributionTextField.isHidden = true
                                
                                if let attribution = medium.attribution {
                                        cell.attributionLabel.text = attribution
                                        
                                        cell.attributionView.isHidden = false
                                } else {
                                        cell.attributionView.isHidden = true
                                }
                        }
                        
                        let itemWidth = collectionView.frame.size.width - 2 * (self.cellSpacing + self.cellPeekWidth)
                        let margin = 12.5
                        
                        let cellViews = [
                                "attributionTextField": cell.attributionTextField,
                                "attributionView": cell.attributionView,
                                "imageViewContainer": cell.imageViewContainer
                        ] as [String : Any]
                        
                        var attributionTextFieldConstraints = NSLayoutConstraint.constraints(
                                withVisualFormat: "V:[imageViewContainer]-(20)-[attributionTextField(==38)]",
                                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                metrics: nil,
                                views: cellViews
                        )
                        attributionTextFieldConstraints += NSLayoutConstraint.constraints(
                                withVisualFormat: "H:|-(\(margin))-[attributionTextField]-(\(margin))-|",
                                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                metrics: nil,
                                views: cellViews
                        )
                        cell.contentView.addConstraints(attributionTextFieldConstraints)
                        
                        var attributionViewConstraints = NSLayoutConstraint.constraints(
                                withVisualFormat: "V:[imageViewContainer]-(20)-[attributionView]|",
                                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                metrics: nil,
                                views: cellViews
                        )
                        attributionViewConstraints += NSLayoutConstraint.constraints(
                                withVisualFormat: "H:|-(\(margin))-[attributionView]-(\(margin))-|",
                                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                metrics: nil,
                                views: cellViews
                        )
                        cell.contentView.addConstraints(attributionViewConstraints)
                        
                        var imageViewContainerConstraints = NSLayoutConstraint.constraints(
                                withVisualFormat: "V:|-(\(margin))-[imageViewContainer(==\(itemWidth - (2 * margin)))]",
                                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                metrics: nil,
                                views: cellViews
                        )
                        imageViewContainerConstraints += NSLayoutConstraint.constraints(
                                withVisualFormat: "H:|-(\(margin))-[imageViewContainer(==\(itemWidth - (2 * margin)))]-(\(margin))-|",
                                options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                metrics: nil,
                                views: cellViews
                        )
                        cell.contentView.addConstraints(imageViewContainerConstraints)
                        
                        cell.deleteButton.addTarget(
                                self,
                                action: #selector(self.userTappedDeleteButton),
                                for: .touchUpInside
                        )
                        
                        if let url = medium.fileURL {
                                // Load again here in case the image doesn't download before the cell is displayed.
                                cell.imageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
                                cell.imageView.sd_imageIndicator?.startAnimatingIndicator()
                                cell.imageView.sd_setImage(with: url) { (image, error, cache, urls) in
                                        if let error = error {
                                                // Failed to load image
                                                print("Failed to load media: \(error)")
                                        } else {
                                                // Success.
                                                cell.imageView.image = image
                                        }
                                }
                        } else if let image = medium.image {
                                cell.imageView.image = image
                                cell.imageView.sd_imageIndicator = nil
                        }
                } else {
                        cell.showsAddMediaButton = true
                        cell.showsDeleteButton = false
                        
                        let addMediaDoubleTapRecognizer = UITapGestureRecognizer(target: self,
                                                                                 action: #selector(self.pasteMedia))
                        addMediaDoubleTapRecognizer.numberOfTapsRequired = 2
                        cell.addMediaButton.addGestureRecognizer(addMediaDoubleTapRecognizer)
                        
                        let addMediaTapRecognizer = UITapGestureRecognizer(target: self,
                                                                           action: #selector(self.presentMediaSourceSelectionSheet))
                        addMediaTapRecognizer.numberOfTapsRequired = 1
                        addMediaTapRecognizer.require(toFail: addMediaDoubleTapRecognizer)
                        cell.addMediaButton.addGestureRecognizer(addMediaTapRecognizer)
                }
                
                return cell
        }
        
        func collectionView(_ collectionView: UICollectionView,
                            canMoveItemAt indexPath: IndexPath) -> Bool {
                var ret = true
                
                if indexPath.item == self.editedMedia.count {
                        ret = false
                }
                
                return ret
        }
        
        func collectionView(_ collectionView: UICollectionView,
                            numberOfItemsInSection section: Int) -> Int {
                return min(NSOAPI.Configuration.productMediaFileCountLimit,
                           self.editedMedia.count + 1)  // +1 for the cell to add media.
        }
        
        func collectionView(_ collectionView: UICollectionView,
                            moveItemAt sourceIndexPath: IndexPath,
                            to destinationIndexPath: IndexPath) {
                let movedMedia = self.editedMedia.remove(at: sourceIndexPath.item)
                self.editedMedia.insert(movedMedia,
                                        at: destinationIndexPath.item)
                collectionView.scrollToItem(at: destinationIndexPath,
                                            at: .centeredHorizontally,
                                            animated: true)
                // Update indices.
                for (index, medium) in self.editedMedia.enumerated() {
                        medium.index = index
                }
                
                self.enableFormButtons()
        }
        
        func collectionView(_ collectionView: UICollectionView,
                            targetIndexPathForMoveOfItemFromOriginalIndexPath originalIndexPath: IndexPath,
                            atCurrentIndexPath currentIndexPath: IndexPath,
                            toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
                var ret = proposedIndexPath
                
                if proposedIndexPath.item == self.editedMedia.count {
                        ret = IndexPath(item: proposedIndexPath.item - 1,
                                        section: proposedIndexPath.section)
                }
                
                return ret
        }
}


// MARK: - UICollectionViewDelegateFlowLayout

extension NSORearrangeableImageCarouselViewController: UICollectionViewDelegateFlowLayout {
        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            sizeForItemAt indexPath: IndexPath) -> CGSize {
                let itemWidth = max(0, collectionView.frame.size.width - 2 * (self.cellSpacing + self.cellPeekWidth))
                
                return CGSize(width: itemWidth,
                              height: collectionView.frame.size.height * 0.8)
        }
        
        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
                return 0
        }
        
        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            minimumLineSpacingForSectionAt section: Int) -> CGFloat {
                return self.cellSpacing
        }
        
        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            insetForSectionAt section: Int) -> UIEdgeInsets {
                let leftAndRightInsets = self.cellSpacing + self.cellPeekWidth
                
                return UIEdgeInsets(
                        top: 0,
                        left: leftAndRightInsets,
                        bottom: 0,
                        right: leftAndRightInsets
                )
        }
}


// MARK: - UIImagePickerControllerDelegate

extension NSORearrangeableImageCarouselViewController: UIImagePickerControllerDelegate,
                                                       UINavigationControllerDelegate {
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
                picker.dismiss(animated: true)
        }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
                var attribution: String?
                var image: UIImage?
                
                if let img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                        image = img
                } else if let img = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                        image = img
                }
                
                if picker.sourceType == .camera {
                        attribution = "Original content."
                }
                
                picker.dismiss(animated: true,
                               completion: {
                        if let image = image {
                                self.addImage(image,
                                              attribution: attribution,
                                              animated: true)
                        }
                })
        }
}


// MARK: - UIScrollViewDelegate

extension NSORearrangeableImageCarouselViewController: UIScrollViewDelegate {
        func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
                self.currentScrollOffset = scrollView.contentOffset
        }
        
        func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                       withVelocity velocity: CGPoint,
                                       targetContentOffset: UnsafeMutablePointer<CGPoint>) {
                let itemWidth = max(0, scrollView.frame.size.width - 2 * (self.cellSpacing + self.cellPeekWidth))
                let target = targetContentOffset.pointee
                /// Current scroll distance is the distance between where the user tapped and
                /// the destination for the scrolling (Ii the velocity is high, this might be of big magnitude).
                let currentScrollDistance = target.x - currentScrollOffset!.x
                /// Make the value an integer between -1 and 1 (because we don't want to scroll
                /// more than one item at a time).
                let coefficent = Int(max(-1, min(currentScrollDistance / self.scrollThreshold, 1)))
                let currentIndex = Int(round(self.currentScrollOffset!.x / itemWidth))
                let adjacentItemIndex = currentIndex + coefficent
                let adjacentItemIndexFloat = CGFloat(adjacentItemIndex)
                let adjacentItemOffsetX = adjacentItemIndexFloat * (itemWidth + self.cellSpacing)
                
                targetContentOffset.pointee = CGPoint(x: adjacentItemOffsetX,
                                                      y: target.y)
        }
}


// MARK: - UITextFieldDelegate

extension NSORearrangeableImageCarouselViewController: UITextFieldDelegate {
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
                textField.resignFirstResponder()
                
                return false
        }
}
