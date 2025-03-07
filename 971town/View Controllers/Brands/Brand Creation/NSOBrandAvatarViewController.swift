//
//  NSOBrandAvatarViewController.swift
//  971town
//
//  Created by Ali Mahouk on 14/02/2023.
//

import API
import UIKit


class NSOBrandAvatarViewController: UIViewController,
                                    UIAdaptivePresentationControllerDelegate,
                                    UIImagePickerControllerDelegate,
                                    UINavigationControllerDelegate {
        private let avatarView: UIImageView
        private let chooseAvatarButton: UIButton
        private let infoLabel: UILabel
        private var nextButton: UIBarButtonItem?
        private var viewIsLoaded: Bool = false
        
        public var brand: NSOBrand
        
        init(brand: NSOBrand) {
                self.brand = brand
                
                let softRoundCornerRadius = UISegmentedControl().layer.cornerRadius
                self.avatarView = UIImageView()
                self.avatarView.contentMode = .scaleAspectFill
                self.avatarView.layer.cornerRadius = softRoundCornerRadius
                self.avatarView.layer.masksToBounds = true
                
                self.chooseAvatarButton = UIButton(type: .system)
                self.chooseAvatarButton.titleLabel?.font = .systemFont(ofSize: 18)
                self.chooseAvatarButton.setTitle("Choose Logo",
                                                 for: .normal)
                self.chooseAvatarButton.sizeToFit()
                
                self.infoLabel = UILabel()
                self.infoLabel.textColor = .systemGray
                self.infoLabel.numberOfLines = 0
                self.infoLabel.text = "Add this brand's logo."
                self.infoLabel.setContentHuggingPriority(.defaultLow,
                                                         for: .vertical)
                
                super.init(nibName: nil,
                           bundle: nil)
                
                self.title = "Brand Logo"
                
                self.chooseAvatarButton.addTarget(
                        self,
                        action: #selector(self.presentMediaLibrary),
                        for: .touchUpInside
                )
        }
        
        required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
        }
        
        private func enableFormButtons() {
                if self.brand.avatar != nil {
                        self.nextButton?.isEnabled = true
                } else {
                        self.nextButton?.isEnabled = false
                }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
                picker.dismiss(animated: true)
        }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
                var image: UIImage?
                
                if let img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                        image = img
                } else if let img = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                        image = img
                }
                
                self.brand.avatar = image
                self.chooseAvatarButton.setTitle("Change Logo",
                                                 for: .normal)
                self.enableFormButtons()
                
                picker.dismiss(animated: true,
                               completion: {
                        self.presentAvatarSelectionView()
                })
        }
        
        func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
                var ret = true
                
                if !self.brand.tags.isEmpty {
                        ret = false
                }
                
                return ret
        }
        
        func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
                let generator = UINotificationFeedbackGenerator()
                generator.prepare()
                
                let confirmationAlert = UIAlertController(
                        title: "Discard Brand?",
                        message: "Any info you entered so far will be lost.",
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
                
                generator.notificationOccurred(.warning)
        }
        
        private func presentAvatarSelectionView() {
                if self.brand.avatar != nil {
                        let animator = UIViewPropertyAnimator(duration: 0.2,
                                                              curve: .easeOut) {
                                self.chooseAvatarButton.frame = CGRect(
                                        x: (self.view.bounds.width / 2) - (self.chooseAvatarButton.bounds.width / 2),
                                        y: self.avatarView.frame.origin.y + self.avatarView.bounds.height + 20,
                                        width: self.chooseAvatarButton.bounds.width,
                                        height: self.chooseAvatarButton.bounds.height
                                )
                        }
                        animator.addCompletion({ _ in
                                self.avatarView.image = self.brand.avatar
                        })
                        animator.startAnimation()
                }
                
                self.enableFormButtons()
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
        private dynamic func updateAvatar() {
                guard self.brand.avatar != nil else { return }
                
                let brandTagsViewController = NSOBrandTagsViewController(brand: self.brand)
                self.navigationController?.pushViewController(brandTagsViewController,
                                                              animated: true)
        }
        
        override func viewDidAppear(_ animated: Bool) {
                super.viewDidAppear(animated)
                
                if !self.viewIsLoaded {
                        self.presentAvatarSelectionView()
                        
                        self.viewIsLoaded = true
                }
                
                self.navigationController?.navigationBar.topItem?.rightBarButtonItem = self.nextButton
                self.navigationController?.presentationController?.delegate = self
        }
        
        override func viewDidLayoutSubviews() {
                super.viewDidLayoutSubviews()
                
                if !self.viewIsLoaded {
                        if self.nextButton == nil {
                                self.nextButton = UIBarButtonItem(
                                        title: "Next",
                                        style: .done,
                                        target: self,
                                        action: #selector(self.updateAvatar)
                                )
                        }
                        
                        let infoLabelSize = self.infoLabel.sizeThatFits(
                                CGSize(
                                        width: self.view.bounds.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right - 80,
                                        height: .greatestFiniteMagnitude
                                )
                        )
                        self.infoLabel.frame = CGRect(
                                x: self.view.safeAreaInsets.left + 40,
                                y: 100,
                                width: self.view.bounds.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right - 80,
                                height: infoLabelSize.height
                        )
                        
                        self.avatarView.frame = CGRect(
                                x: (self.view.bounds.width / 2) - 100,
                                y: (self.view.bounds.height / 2) - 100,
                                width: 200,
                                height: 200
                        )
                        self.chooseAvatarButton.frame = CGRect(
                                x: (self.view.bounds.width / 2) - (self.chooseAvatarButton.bounds.width / 2),
                                y: (self.view.bounds.height / 2) - (self.chooseAvatarButton.bounds.height / 2),
                                width: self.chooseAvatarButton.bounds.width,
                                height: self.chooseAvatarButton.bounds.height
                        )
                        
                        self.view.addSubview(self.infoLabel)
                        self.view.addSubview(self.avatarView)
                        self.view.addSubview(self.chooseAvatarButton)
                }
        }
        
        override func viewDidLoad() {
                super.viewDidLoad()
                
                self.view.backgroundColor = .white
        }
}
