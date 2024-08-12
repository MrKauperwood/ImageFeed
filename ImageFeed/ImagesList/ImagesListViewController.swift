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
    private var photosName: [String] = []
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
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.delegate = self
        tableView.dataSource = self
        
        // Инициализация photosName
        photosName = imageListService.photos.map { "\($0)" }
        
        // Подписка на уведомление
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(photosDidChange),
            name: ImagesListService.didChangeNotification,
            object: nil
        )
        
        // Инициация первой загрузки фотографий
//        initiateFirstLoad()
    }
    
    @objc private func photosDidChange() {
        photosName = imageListService.photos.map { "\($0)" }
        tableView.reloadData()
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
            
            let imageName = photosName[indexPath.row]
            let image = UIImage(named: imageName)
            
            if image == nil {
                print("Image is nil for \(imageName)")
            } else {
                print("Image \(imageName) loaded successfully")
            }
            
            viewController.image = image
        }
        else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = UIImage(named: photosName[indexPath.row]) else {
            return 0
        }
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.size.width
        let imageHeight = image.size.height
        
        let scale = imageViewWidth / imageWidth
        let cellHeight = imageHeight * scale + imageInsets.top + imageInsets.bottom
        
        return cellHeight
    }
    
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        // Проверяем, если ли ячейка последняя
        if indexPath.row + 1 == photosName.count {
            
            guard let token = storage.getTokenFromStorage() else {
                print("Failed to retrieve token")
                return // Прерываем выполнение, если нет токена
            }
            
//            // Убедимся, что нет активного запроса
//            if imageListService.task == nil {
//                imageListService.fetchPhotosNextPage(token: token) { [weak self] result in
//                    switch result {
//                    case .success(let message):
//                        print("Success: \(message)")
//                        // Обновляем данные таблицы
//                        DispatchQueue.main.async {
//                            self?.tableView.reloadData()
//                        }
//                    case .failure(let error):
//                        print("Error: \(error.localizedDescription)")
//                    }
//                }
//            } else {
//                print("Request is already in progress, skipping new fetch")
//            }
        }
        print("Привет")
    }
    
    private func initiateFirstLoad() {
        guard let token = storage.getTokenFromStorage() else {
            print("Failed to retrieve token")
            return
        }

        imageListService.fetchPhotosNextPage(token: token) { [weak self] result in
            switch result {
            case .success(let message):
                print("Success: \(message)")
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosName.count
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
        guard let image = UIImage(named: photosName[indexPath.row]) else {
            return
        }
        cell.cellImage.image = image
        
        let currentDate = Date()
        let dateString = dateFormatter.string(from: currentDate)
        cell.dateLabel.text = dateString
        
        let isLiked = indexPath.row % 2 != 0
        let likeImage = isLiked ? UIImage(named: "ActiveLike") : UIImage(named: "NotActiveLike")
        cell.likeButton.setImage(likeImage, for: .normal)
    }
    
}
