//
//  NSOImageCarouselView.swift
//  971town
//
//  Created by Ali Mahouk on 25/03/2023.
//

import SDWebImage
import UIKit


class NSOImageCarouselView: UIView {
        private let pageControl = UIPageControl()
        private let scrollView = UIScrollView()
        
        public let editButton = UIButton(type: .system)
        public var images: [UIImage] = [] {
                didSet {
                        if !self.urls.isEmpty {
                                self.urls.removeAll()
                        }
                        
                        self.setupImageCarousel()
                }
        }
        public var urls: [URL] = [] {
                didSet {
                        if !self.images.isEmpty {
                                self.images.removeAll()
                        }
                        
                        self.setupImageCarousel()
                }
        }
        
        
        init() {
                super.init(frame: .zero)
                
                self.configureSubviews()
        }
        
        required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
        }
        
        private func configureSubviews() {
                var editButtonConfig = UIButton.Configuration.plain()
                editButtonConfig.image = UIImage(systemName: "camera.viewfinder",
                                                 withConfiguration: UIImage.SymbolConfiguration(pointSize: 64, weight: .thin))
                editButtonConfig.imagePadding = 20
                editButtonConfig.imagePlacement = .top
                editButtonConfig.title = "Update Media"
                self.editButton.configuration = editButtonConfig
                
                self.pageControl.currentPageIndicatorTintColor = .black
                self.pageControl.hidesForSinglePage = true
                self.pageControl.pageIndicatorTintColor = .systemGray3
                self.pageControl.addTarget(
                        self,
                        action: #selector(self.pageControlValueChanged),
                        for: .valueChanged
                )
                
                self.scrollView.delegate = self
                self.scrollView.isPagingEnabled = true
                self.scrollView.scrollsToTop = false
                self.scrollView.showsHorizontalScrollIndicator = false
                
                self.addSubview(self.scrollView)
                self.addSubview(self.pageControl)
                
                self.scrollView.translatesAutoresizingMaskIntoConstraints = false
                self.pageControl.translatesAutoresizingMaskIntoConstraints = false
                
                NSLayoutConstraint.activate([
                        self.scrollView.topAnchor.constraint(equalTo: self.topAnchor),
                        self.scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                        self.scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                        self.scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                        
                        self.pageControl.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                        self.pageControl.bottomAnchor.constraint(equalTo: self.bottomAnchor,
                                                                 constant: -8)
                ])
        }
        
        @objc
        private dynamic func pageControlValueChanged(_ pageControl: UIPageControl) {
                self.setCurrentPage(pageControl.currentPage,
                                    animated: false)
        }
        
        public func setCurrentPage(_ page: Int,
                                   animated: Bool) {
                var rect = bounds
                rect.origin.x = rect.width * CGFloat(page)
                rect.origin.y = 0
                self.scrollView.scrollRectToVisible(rect,
                                                    animated: animated)
        }
        
        private func setupImageCarousel() {
                /// Clear out.
                for subview in self.scrollView.subviews {
                        subview.removeFromSuperview()
                }
                
                /// Reset the page control.
                for i in 0..<self.pageControl.numberOfPages {
                        self.pageControl.setIndicatorImage(nil,
                                                           forPage: i)
                }
                
                if !self.images.isEmpty {
                        for (index, image) in self.images.enumerated() {
                                let imageView = UIImageView(image: image)
                                imageView.backgroundColor = .white
                                imageView.contentMode = .scaleAspectFill
                                imageView.clipsToBounds = true
                                imageView.frame = CGRect(
                                        x: CGFloat(index) * self.bounds.width,
                                        y: 0,
                                        width: self.bounds.width,
                                        height: self.bounds.height
                                )
                                self.scrollView.addSubview(imageView)
                        }
                        
                        self.editButton.frame = CGRect(
                                x: CGFloat(self.images.count) * self.bounds.width,
                                y: 0,
                                width: self.bounds.width,
                                height: self.bounds.height
                        )
                        self.scrollView.addSubview(self.editButton)
                        
                        self.scrollView.contentSize = CGSize(
                                width: self.bounds.width * CGFloat(self.images.count + 1), // +1 for the Edit button.
                                height: self.bounds.height
                        )
                        
                        self.pageControl.numberOfPages = self.images.count + 1
                        self.pageControl.setIndicatorImage(
                                UIImage(systemName: "camera.fill",
                                        withConfiguration: UIImage.SymbolConfiguration(pointSize: 9, weight: .regular)),
                                forPage: self.pageControl.numberOfPages - 1
                        )
                } else if !self.urls.isEmpty {
                        for (index, url) in self.urls.enumerated() {
                                let imageView = UIImageView(
                                        frame: CGRect(
                                                x: CGFloat(index) * self.bounds.width,
                                                y: 0,
                                                width: self.bounds.width,
                                                height: self.bounds.height
                                        )
                                )
                                imageView.backgroundColor = .white
                                imageView.contentMode = .scaleAspectFill
                                imageView.clipsToBounds = true
                                imageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
                                imageView.sd_imageIndicator?.startAnimatingIndicator()
                                imageView.sd_setImage(with: url)
                                self.scrollView.addSubview(imageView)
                        }
                        
                        self.editButton.frame = CGRect(
                                x: CGFloat(self.urls.count) * self.bounds.width,
                                y: 0,
                                width: self.bounds.width,
                                height: self.bounds.height
                        )
                        self.scrollView.addSubview(self.editButton)
                        
                        self.scrollView.contentSize = CGSize(
                                width: self.bounds.width * CGFloat(self.urls.count + 1), // +1 for the Edit button.
                                height: self.bounds.height
                        )
                        
                        self.pageControl.numberOfPages = self.urls.count + 1
                        self.pageControl.setIndicatorImage(
                                UIImage(systemName: "camera.fill",
                                        withConfiguration: UIImage.SymbolConfiguration(pointSize: 9, weight: .regular)),
                                forPage: self.pageControl.numberOfPages - 1
                        )
                } else {
                        self.editButton.frame = self.bounds
                        self.scrollView.addSubview(self.editButton)
                        
                        self.scrollView.contentSize = CGSize(
                                width: self.bounds.width,
                                height: self.bounds.height
                        )
                        
                        self.pageControl.numberOfPages = 1
                }
                
                if self.bounds.width > 0
                        && scrollView.contentOffset.x > 0 {
                        /// The above check is to prevent the delegate method from firing
                        /// on a zero-width scroll view.
                        self.scrollView.scrollRectToVisible(
                                CGRect(
                                        x: 0,
                                        y: 0,
                                        width: self.bounds.width,
                                        height: self.bounds.height),
                                animated: false
                        )
                }
        }
        
        override func layoutSubviews() {
                self.setupImageCarousel()
        }
}


extension NSOImageCarouselView: UIScrollViewDelegate {
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
                let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.width)
                self.pageControl.currentPage = Int(pageIndex)
        }
}
