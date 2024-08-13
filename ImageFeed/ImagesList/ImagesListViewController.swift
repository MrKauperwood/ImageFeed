//
//  ViewController.swift
//  ImageFeed
//
//  Created by Aleksei Bondarenko on 24.4.2024.
//

import UIKit

final class ImagesListViewController: UIViewController {
    
    // MARK: - IB Outlets
    @IBOutlet private  var tableView: UITableView!
    
    // MARK: - Private Properties
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    //    private var photosName: [String] = []
    private var photos: [Photo] = []
    private var isLoadingNewPhotos = false
    
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }()
    private let storage = OAuth2TokenActions()
    
    let imageListService = ImagesListService()
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Настройка tableView
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.delegate = self
        tableView.dataSource = self
        
        // Подписка на уведомление
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(photosDidChange),
            name: ImagesListService.didChangeNotification,
            object: nil
        )
        
        initiateFirstLoadIfNeeded {
            self.hideLoadingIndicator()
        }
        print("Check")
    }
    
    private func showLoadingIndicator() {
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }
    
    
    @objc private func photosDidChange() {
        print("photosDidChange called")
        updateTableViewAnimated()
    }
    
    func updateTableViewAnimated() {
        guard !imageListService.photos.isEmpty else { return }
        
        photos = imageListService.photos
        
        let oldCount = photos.count
        let newCount = imageListService.photos.count
        photos = imageListService.photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { success in
                if !success {
                    // Если анимация не удалась, перезагружаем таблицу
                    self.tableView.reloadData()
                }}
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: ImagesListService.didChangeNotification, object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            
            let photo = photos[indexPath.row]
            print("А это юрл для фото \(photo.largeImageURL)")
            
            // Загружаем изображение с помощью Kingfisher
            if let url = URL(string: photo.largeImageURL) {
                viewController.imageView.kf.setImage(with: url) { result in
                    switch result {
                    case .success(let value):
                        print("Image \(photo.largeImageURL) loaded successfully")
                        viewController.image = value.image
                    case .failure(let error):
                        print("Image loading error: \(error.localizedDescription)")
                        viewController.image = nil
                    }
                }
            } else {
                print("Invalid URL: \(photo.largeImageURL)")
                viewController.image = nil
            }
        }
        else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected row at indexPath: \(indexPath.row)")
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //        guard let image = UIImage(named: photosName[indexPath.row]) else {
        //            return 0
        //        }
        //
        //        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        //
        //        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        //        let imageWidth = image.size.width
        //        let imageHeight = image.size.height
        //
        //        let scale = imageViewWidth / imageWidth
        //        let cellHeight = imageHeight * scale + imageInsets.top + imageInsets.bottom
        return UITableView.automaticDimension
        
        //        return cellHeight
    }
    
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        // Проверяем, если ли ячейка последняя
        if indexPath.row + 1 == photos.count && !isLoadingNewPhotos {
            
            guard let token = storage.getTokenFromStorage() else {
                print("Failed to retrieve token")
                return // Прерываем выполнение, если нет токена
            }
            
            isLoadingNewPhotos = true
            
            // Убедимся, что нет активного запроса
            if imageListService.task == nil {
                imageListService.fetchPhotosNextPage(token: token) { [weak self] result in
                    guard let self = self else { return }
                    
                    DispatchQueue.main.async {
                        self.isLoadingNewPhotos = false // Сбрасываем флаг после завершения загрузки
                        
                        switch result {
                        case .success(let message):
                            print("Success: \(message)")
                            // Обновляем данные таблицы
                            self.tableView.reloadData()
                        case .failure(let error):
                            print("Error: \(error.localizedDescription)")
                        }
                    }
                }
            } else {
                print("Request is already in progress, skipping new fetch")
            }
        }
        print("Готовим ячейку")
    }
    
    private func initiateFirstLoadIfNeeded(completion: @escaping () -> Void) {
        self.showLoadingIndicator()
        
        if isLoadingNewPhotos || imageListService.photos.count != 0 {
            completion()
            return
        }
        
        isLoadingNewPhotos = true
        
        guard let token = storage.getTokenFromStorage() else {
            print("Failed to retrieve token")
            completion()
            return
        }
        
        imageListService.fetchPhotosNextPage(token: token) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoadingNewPhotos = false // Сбрасываем флаг после завершения загрузки
                self.hideLoadingIndicator()
                switch result {
                case .success(let message):
                    print("Success: \(message)")
                    self.tableView.reloadData()
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
                completion()
            }
            
        }
    }
    
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}

extension ImagesListViewController{
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        
        let photo = photos[indexPath.row]
        
        // Устанавливаем заглушку на время загрузки
        let placeholderImage = UIImage(named: "RectangleBlur")
        
        // Устанавливаем тип индикатора активности
        cell.cellImage.kf.indicatorType = .activity
        
        print("Loading image from URL: \(photo.thumbImageURL)")
        
        // Загружаем изображение с использованием Kingfisher
        if let url = URL(string: photo.thumbImageURL) {
            cell.cellImage.kf.setImage(with: url, placeholder: placeholderImage, options: nil, completionHandler:  { [weak self] result in
                switch result {
                case .success(_):
                    // Обновляем высоту ячейки после загрузки изображения
                    self?.tableView.beginUpdates()
                    self?.tableView.endUpdates()
                case .failure(let error):
                    print("Image loading error: \(error)")
                }
            })
        } else {
            cell.cellImage.image = placeholderImage
        }
        
        // Устанавливаем дату создания
        if let createdAt = photo.createdAt {
            cell.dateLabel.text = dateFormatter.string(from: createdAt)
        }
        
        // Устанавливаем состояние кнопки "лайк"
        let likeImage = photo.isLiked ? UIImage(named: "ActiveLike") : UIImage(named: "NotActiveLike")
        cell.likeButton.setImage(likeImage, for: .normal)
    }
    
}
