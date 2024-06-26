//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Aleksei Bondarenko on 2.6.2024.
//

import Foundation
import UIKit

final class SingleImageViewController: UIViewController {
    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image else {
                print("Image not set in didSet")
                return
            }
            imageView.image = image
            
            //            imageView.frame.size = image.size
            //            rescaleAndCenterImageInScrollView(image: image)
            updateImageViewConstraints()
        }
    }
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var imageView: UIImageView!
    
    @IBAction func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapShareButton(_ sender: UIButton) {
        guard let image = image else {
            print("Image is nil")
            return
        }
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        
        present(activityViewController, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        
        imageView.contentMode = .scaleAspectFill
        setupScrollViewConstraints()
        setupImageViewConstraints()
        
        guard let image = image else {
            print("Image is nil")
            return
        }
        imageView.frame.size = UIScreen.main.bounds.size
        imageView.image = image
        updateImageViewConstraints()
        //        rescaleAndCenterImageInScrollView(image: image)
    }
    
    private func updateImageViewConstraints() {
        guard let image = image else { return }
        
        // Рассчитываем новый размер для imageView в зависимости от размеров изображения
        let imageViewSize = calculateImageViewSize(for: image)
        
        // Удаляем старые констрейнты ширины и высоты, если они существуют
        NSLayoutConstraint.deactivate(imageView.constraints.filter {
            $0.firstAttribute == .width || $0.firstAttribute == .height
        })
        
        // Устанавливаем новые констрейнты ширины и высоты для imageView
        let widthConstraint = imageView.widthAnchor.constraint(equalToConstant: imageViewSize.width)
        let heightConstraint = imageView.heightAnchor.constraint(equalToConstant: imageViewSize.height)
        
        widthConstraint.isActive = true
        heightConstraint.isActive = true
        
        // Обновляем contentSize для scrollView
        scrollView.contentSize = imageViewSize
        
        // Центрируем imageView
        centerImageView()
    }
    
    private func calculateImageViewSize(for image: UIImage) -> CGSize {
        let widthScale = scrollView.bounds.width / image.size.width
        let heightScale = scrollView.bounds.height / image.size.height
        let scale = max(widthScale, heightScale)
        let width = image.size.width * scale
        let height = image.size.height * scale
        return CGSize(width: width, height: height)
    }
    
    private func centerImageView() {
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0.0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0.0)
        imageView.center = CGPoint(x: scrollView.contentSize.width / 2 + offsetX, y: scrollView.contentSize.height / 2 + offsetY)
    }
    
    private func setupScrollViewConstraints() {
         scrollView.translatesAutoresizingMaskIntoConstraints = false
         NSLayoutConstraint.activate([
             // Устанавливаем констрейнты для scrollView относительно его superview
             scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
             scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
             scrollView.topAnchor.constraint(equalTo: view.topAnchor),
             scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
         ])
     }

    
    private func setupImageViewConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            // Привязываем imageView к краям scrollView
            imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])
    }
    
    
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        //                let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0.0)
        //                let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0.0)
        //                scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: offsetY, right: offsetX)
        
        centerImageView()}
}
