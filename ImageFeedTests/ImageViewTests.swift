//
//  ImageViewTests.swift
//  ImageFeedTests
//
//  Created by Aleksei Bondarenko on 21.8.2024.
//

import XCTest
@testable import ImageFeed

final class ImageFeedTests: XCTestCase {
    
    var viewController: ImagesListViewController!
    var imageListServiceMock: ImageListServiceMock!
    var tokenStorageMock: OAuth2TokenActionsMock!
    
    override func setUp() {
        super.setUp()
        
        imageListServiceMock = ImageListServiceMock()
        tokenStorageMock = OAuth2TokenActionsMock()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as? ImagesListViewController
        viewController.imageListService = imageListServiceMock
        viewController.storage = tokenStorageMock
        
        // Принудительно загружаем view
        _ = viewController.view
    }
    
    override func tearDown() {
        viewController = nil
        imageListServiceMock = nil
        tokenStorageMock = nil
        
        super.tearDown()
    }
    
    func testSetUpTableView() {
        viewController.loadViewIfNeeded() // Загружаем view
        
        let tableView = viewController.tableView
        
        XCTAssertNotNil(tableView, "tableView is nil")
        XCTAssertNotNil(tableView?.delegate, "tableView delegate is nil")
        XCTAssertNotNil(tableView?.dataSource, "tableView dataSource is nil")
    }
    
    func testShowLoadingIndicatorAndFetchPhotos() {
        viewController.initiateFirstLoadIfNeeded {
            
            XCTAssertTrue(self.imageListServiceMock.fetchPhotosNextPageCalled)
            XCTAssertTrue(self.tokenStorageMock.getTokenFromStorageCalled)
        }
    }
    
    func testUpdateTableView() {
        // Создаем фото
        let photo = Photo(
            id: "1",
            size: CGSize(),
            createdAt: Date(),
            welcomeDescription: "",
            thumbImageURL: "",
            smallImageURL: "",
            largeImageURL: "",
            isLiked: false)
        
        
        imageListServiceMock.photosMock = [photo]
        viewController.photosDidChange()
        
        XCTAssertEqual(viewController.tableView.numberOfRows(inSection: 0), 1)
    }
    
    func testPrepareForSegue() {
        let photo = Photo(
            id: "1",
            size: CGSize(),
            createdAt: Date(),
            welcomeDescription: "",
            thumbImageURL: "",
            smallImageURL: "",
            largeImageURL: "",
            isLiked: false)
        
        imageListServiceMock.photosMock = [photo]
        viewController.photos = imageListServiceMock.photosMock
        
        let segue = UIStoryboardSegue(identifier: "ShowSingleImage", source: viewController, destination: SingleImageViewController())
        viewController.prepare(for: segue, sender: IndexPath(row: 0, section: 0))
        
        let destinationVC = segue.destination as? SingleImageViewController
        XCTAssertEqual(destinationVC?.imageUrl, photo.largeImageURL, "URL изображения должен быть передан в SingleImageViewController")
    }
    
    func testLoadMorePhotosOnScroll() {
        imageListServiceMock.photosMock = Array(repeating: Photo(
            id: "1",
            size: CGSize(),
            createdAt: Date(),
            welcomeDescription: "",
            thumbImageURL: "",
            smallImageURL: "",
            largeImageURL: "",
            isLiked: false), count: 10)
        
        viewController.photos = imageListServiceMock.photosMock
        
        viewController.loadViewIfNeeded()
        viewController.tableView.reloadData()
        
        let lastIndexPath = IndexPath(row: 9, section: 0)
        viewController.tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: false)
        
        viewController.tableView(viewController.tableView, willDisplay: UITableViewCell(), forRowAt: lastIndexPath)
        
        XCTAssertTrue(imageListServiceMock.fetchPhotosNextPageCalled, "Должен быть вызван метод загрузки следующей страницы фотографий при прокрутке до конца списка")
    }
}

// Мок для сервиса загрузки изображений
final class ImageListServiceMock: ImagesListService {
    var photosMock: [Photo] = []
    var didChangeNotification = Notification.Name("ImagesListService.didChangeNotification")
    
    override var photos: [Photo] {
        return photosMock
    }
    
    var fetchPhotosNextPageCalled = false
    var changeLikeCalled = false
    
    override func fetchPhotosNextPage(token: String, completion: @escaping (Result<String, Error>) -> Void) {
        fetchPhotosNextPageCalled = true
        completion(.success("Success"))
    }
    
    override func changeLike(photoId: String, isLike: Bool, token: String, _ completion: @escaping (Result<Void, Error>) -> Void) {
        changeLikeCalled = true
        completion(.success(()))
    }
}

// Мок для хранения токенов
final class OAuth2TokenActionsMock: OAuth2TokenActions {
    var getTokenFromStorageCalled = false
    
    override func getTokenFromStorage() -> String? {
        getTokenFromStorageCalled = true
        return "MockToken"
    }
}
