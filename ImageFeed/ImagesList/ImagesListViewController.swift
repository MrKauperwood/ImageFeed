//
//  ViewController.swift
//  ImageFeed
//
//  Created by Aleksei Bondarenko on 24.4.2024.
//

import UIKit

protocol ImagesListControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get set }
}


final class ImagesListViewController: UIViewController, ImagesListControllerProtocol {
    
    // MARK: - IB Outlets
    @IBOutlet var tableView: UITableView!
    
    // MARK: - Private Properties
    var presenter: ImagesListPresenterProtocol?
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    var photos: [Photo] = []
    private var isLoadingNewPhotos = false
    
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }()
    private var storage = OAuth2TokenActions()
    private var imageListService = ImagesListService()
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Настройка индикатора, чтобы он скрывался автоматически
        activityIndicator.hidesWhenStopped = true
        
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
    }
    
    private func showLoadingIndicator() {
//        activityIndicator.center = self.view.center
//        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
//        activityIndicator.removeFromSuperview()
    }
    
    @objc func photosDidChange() {
        updateTableViewAnimated()
    }
    
    func updateTableViewAnimated() {
        guard !imageListService.photos.isEmpty else { return }
        
        let oldCount = photos.count
        let newCount = imageListService.photos.count
        
        if oldCount != newCount {
            tableView.performBatchUpdates {
                photos = imageListService.photos
                
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { success in
                if !success {
                    // Если анимация не удалась, перезагружаем таблицу
                    self.photos = self.imageListService.photos
                    self.tableView.reloadData()
                }
            }
        } else {
            // Если количество фото не изменилось, обновляем массив photos
            photos = imageListService.photos
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
            viewController.imageUrl = photo.largeImageURL
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Logger.logMessage("Selected row at indexPath: \(indexPath.row)", for: self, level: .info)
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        // Проверяем, последняя ли ячейка
        if indexPath.row + 1 == photos.count && !isLoadingNewPhotos {
            
            guard let token = storage.getTokenFromStorage() else {
                Logger.logMessage("Failed to retrieve token", for: self, level: .error)
                return
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
                            Logger.logMessage("Success: \(message)", for: self, level: .info)
                        case .failure(let error):
                            Logger.logMessage("Error: \(error.localizedDescription)", for: self, level: .error)
                        }
                    }
                }
            } else {
                Logger.logMessage("Request is already in progress, skipping new fetch", for: self, level: .warning)
            }
        }
    }
    
    func initiateFirstLoadIfNeeded(completion: @escaping () -> Void) {
        self.showLoadingIndicator()
        
        if isLoadingNewPhotos || imageListService.photos.count != 0 {
            completion()
            return
        }
        
        isLoadingNewPhotos = true
        
        guard let token = storage.getTokenFromStorage() else {
            Logger.logMessage("Failed to retrieve token", for: self, level: .error)
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
                    Logger.logMessage("Success: \(message)", for: self, level: .info)
                case .failure(let error):
                    Logger.logMessage("Error: \(error.localizedDescription)", for: self, level: .error)
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
        
        imageListCell.delegate = self
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        
        let placeholderImage = UIImage(named: "RectangleBlur")
        
        cell.cellImage.kf.indicatorType = .activity
        
        if let url = URL(string: photo.smallImageURL) {
            cell.cellImage.kf.setImage(with: url, placeholder: placeholderImage, options: nil, completionHandler:  { [weak self] result in
                switch result {
                case .success(_):
                    // Обновляем конкретную ячейку после загрузки изображения
                    self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                case .failure(let error):
                    Logger.logMessage("Image loading error: \(error)", for: "ImagesListViewController", level: .error)
                }
            })
        } else {
            cell.cellImage.image = placeholderImage
        }
        
        if let createdAt = photo.createdAt {
            cell.dateLabel.text = dateFormatter.string(from: createdAt)
        } else {
            cell.dateLabel.text = ""
        }
        
        let likeImage = photo.isLiked ? UIImage(named: "ActiveLike") : UIImage(named: "NotActiveLike")
        cell.likeButton.setImage(likeImage, for: .normal)
        
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        
        // Добавляем вибрацию при нажатии на лайк
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        feedbackGenerator.impactOccurred()
        
        // Анимация лайка
        animateLikeButton(cell.likeButton, isLiked: !photo.isLiked)
        
        // Блокируем взаимодействие с интерфейсом
        self.view.isUserInteractionEnabled = false
        
        guard let token = self.storage.getTokenFromStorage() else {
            Logger.logMessage("Failed to retrieve token", for: self, level: .error)
            self.view.isUserInteractionEnabled = true // Разблокируем интерфейс в случае ошибки
            return
        }
        
        imageListService.changeLike(photoId: photo.id, isLike: !photo.isLiked, token: token) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.view.isUserInteractionEnabled = true // Разблокируем интерфейс
                switch result {
                case .success:
                    self.photos = self.imageListService.photos
                    cell.setIsLiked(self.photos[indexPath.row].isLiked)
                case .failure(let error):
                    self.showErrorAlert(error: error)
                }
            }
        }
    }
}

private func animateLikeButton(_ button: UIButton, isLiked: Bool) {
    // Устанавливаем начальное состояние кнопки (например, масштаб 1.3)
    button.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
    
    // Обновляем изображение кнопки сразу перед началом анимации
    let likeImage = isLiked ? UIImage(named: "ActiveLike") : UIImage(named: "NotActiveLike")
    button.setImage(likeImage, for: .normal)
    
    // Анимация уменьшения обратно до нормального размера
    UIView.animate(withDuration: 0.3,
                   delay: 0,
                   usingSpringWithDamping: 0.5,
                   initialSpringVelocity: 0.5,
                   options: .curveEaseInOut,
                   animations: {
                    button.transform = CGAffineTransform.identity
                   }, completion: nil)
}

extension ImagesListViewController {
    
    func showErrorAlert(error: Error) {
        let alertController = UIAlertController(title: "Ошибка", message: error.localizedDescription, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

