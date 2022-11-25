//
//  PhotosViewController.swift
//  Collage
//
//  Created by ming on 2022/11/24.
//

import UIKit
import Photos
import Combine

private let reuseIdentifier = "Cell"

class PhotosViewController: UICollectionViewController {
    
    @Published var selectedPhotosCount = 0
    
    //MARK: - Public properties
    var selectedPhotos: AnyPublisher<UIImage, Never> {
        return selectedPhotosSubject.eraseToAnyPublisher()
    }
    
    //MARK: - Private properties
    private let selectedPhotosSubject = PassthroughSubject<UIImage, Never>()
    
    private var subscriptions = Set<AnyCancellable>()
    
    private lazy var photos = PhotosViewController.loadPhotos()
    private lazy var imageManager = PHCachingImageManager()
    
    lazy var thumbnailSize: CGSize = {
        let cellSize = (self.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        return CGSize(
            width: cellSize.width * UIScreen.main.scale,
            height: cellSize.height * UIScreen.main.scale
        )
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        PHPhotoLibrary.isAuthorized
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isAuthorized in
                if isAuthorized {
                    self?.photos = PhotosViewController.loadPhotos()
                    self?.collectionView.reloadData()
                } else {
                    self?.showErrorMessage()
                }
            }
            .store(in: &subscriptions)
    }
    
    
    func showErrorMessage() {
        alert(title: "No access to Camera Roll", text: "You can grant access to Collage from the Settings app")
            .sink { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
                self?.navigationController?.popViewController(animated: true)
            } receiveValue: { _ in }
            .store(in: &subscriptions)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        selectedPhotosSubject.send(completion: .finished)
    }

    // MARK: UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return photos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let asset = photos.object(at: indexPath.item)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCell
        
        cell.representedAssetIdentifier = asset.localIdentifier
        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil) { image, _ in
            if cell.representedAssetIdentifier == asset.localIdentifier {
                cell.preview.image = image
            }
        }

        return cell
    }

    // MARK: - UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = photos.object(at: indexPath.item)
        if let cell = collectionView.cellForItem(at: indexPath) as? PhotoCell {
            cell.flash()
        }
        
        imageManager.requestImage(for: asset, targetSize: view.frame.size, contentMode: .aspectFill, options: nil) { [weak self] image, info in
            guard let self, let image, let info else { return }
            
            if let isThumbnail = info[PHImageResultIsDegradedKey as String] as? Bool, isThumbnail {
                return 
            }
            
            self.selectedPhotosSubject.send(image)
            
            self.selectedPhotosCount += 1
        }
    }

}

extension PhotosViewController {
    static func loadPhotos() -> PHFetchResult<PHAsset> {
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        return PHAsset.fetchAssets(with: allPhotosOptions)
    }
}
