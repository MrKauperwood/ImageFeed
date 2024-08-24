//
//  ViewController.swift
//  ImageFeed
//
//  Created by Aleksei Bondarenko on 24.4.2024.
//

import UIKit

protocol ImagesListControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get set }
    
    func updateTableView()
    func updateLikeState(at index: Int)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func updateTableViewAnimated()
}


final class ImagesListViewController: UIViewController, ImagesListControllerProtocol {
    
    // MARK: - IB Outlets
    @IBOutlet var tableView: UITableView!
    
    var presenter: ImagesListPresenterProtocol?
    
    // MARK: - Private Properties
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }()
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Настройка индикатора, чтобы он скрывался автоматически
        activityIndicator.hidesWhenStopped = true
        
        // Настройка tableView
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.delegate = self
        tableView.dataSource = self
        
        presenter?.loadInitialPhotos { [weak self] in
            self?.hideLoadingIndicator()
        }
    }
    
    func updateTableView() {
        tableView.reloadData()
    }
    
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    @objc func photosDidChange() {
        updateTableViewAnimated()
    }
    
    func updateLikeState(at index: Int) {
        guard let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? ImagesListCell else { return }
        let photo = presenter?.photos[index]
        let likeImage = photo?.isLiked ?? false ? UIImage(named: "ActiveLike") : UIImage(named: "NotActiveLike")
        cell.likeButton.setImage(likeImage, for: .normal)
    }
    
    
    
    func updateTableViewAnimated() {
        guard let presenter = presenter else { return }
        let oldCount = presenter.photos.count
        
        presenter.loadMorePhotosIfNeeded(for: oldCount)
        
        let newCount = presenter.photos.count
        
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { success in
                if !success {
                    self.tableView.reloadData()
                }
            }
        } else {
            tableView.reloadData()
        }
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: ImagesListService.didChangeNotification, object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath,
                let photo = presenter?.photos[indexPath.row]
            else {
                assertionFailure("Invalid segue destination")
                return
            }
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
        presenter?.loadMorePhotosIfNeeded(for: indexPath.row)
    }
    
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.photos.count ?? 0
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
        guard let photo = presenter?.photos[indexPath.row] else { return }
        
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
        
        // Добавляем вибрацию при нажатии на лайк
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        feedbackGenerator.impactOccurred()
        
        // Анимация лайка
        animateLikeButton(cell.likeButton, isLiked: !(presenter?.photos[indexPath.row].isLiked ?? false))
        
        presenter?.toggleLike(at: indexPath.row) { [weak self] result in
            DispatchQueue.main.async {
                self?.view.isUserInteractionEnabled = true
                switch result {
                case .success(let isLiked):
                    cell.setIsLiked(isLiked)
                case .failure(let error):
                    self?.showErrorAlert(error: error)
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
