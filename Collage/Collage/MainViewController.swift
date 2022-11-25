//
//  MainViewController.swift
//  Collage
//
//  Created by ming on 2022/11/24.
//

import UIKit
import Combine

class MainViewController: UIViewController {
    
    private var subscriptions = Set<AnyCancellable>()
    private let images = CurrentValueSubject<[UIImage], Never>([])
    
    @IBOutlet weak var imagePreview: UIImageView! {
        didSet {
            imagePreview.layer.borderColor = UIColor.gray.cgColor
        }
    }
    
    @IBOutlet weak var buttonClear: UIButton!
    
    @IBOutlet weak var buttonSave: UIButton!
    
    @IBOutlet weak var itemAdd: UIBarButtonItem!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let collageSize = imagePreview.frame.size
        
        images
            .handleEvents(receiveOutput: { [weak self] photos in
                self?.updateUI(photos: photos)
            })
            .map { photos in
                UIImage.collage(images: photos, size: collageSize)
            }
            .assign(to: \.image, on: imagePreview)
            .store(in: &subscriptions)
        
        
    }
    
    private func updateUI(photos: [UIImage]) {
        buttonSave.isEnabled = photos.count > 0 && photos.count % 2 == 0
        buttonClear.isEnabled = photos.count > 0
        itemAdd.isEnabled = photos.count < 6
        title = photos.count > 0 ? "\(photos.count) photos" : "Collage"
    }
    
    @IBAction func actionClear() {
        images.send([])
    }
    
    @IBAction func actionSave() {
        guard let image = imagePreview.image else { return }
        
        PhotoWriter.save(image)
            .sink { [unowned self] completion in
                if case .failure(let error) = completion {
                    self.showMessage("Error", description: error.localizedDescription)
                }
                self.actionClear()
            } receiveValue: { [unowned self] id in
                self.showMessage("Saved with id: \(id)")
            }
            .store(in: &subscriptions)

    }
    
    
    @IBAction func actionAdd() {

        let photos = storyboard!.instantiateViewController(withIdentifier: "PhotosViewController") as! PhotosViewController
        
        photos.$selectedPhotosCount
            .filter { $0 > 0 }
            .map { "Selected \($0) photos"}
            .assign(to: \.title, on: self)
            .store(in: &subscriptions)
        
        let newPhotos = photos.selectedPhotos
            .print("new photos:")
            .prefix(while: { [unowned self] _ in
                return self.images.value.count < 6
            })
            .filter({ newImage in
                return newImage.size.width > newImage.size.height
            })
            .share()
        
        newPhotos
            .ignoreOutput()
            .filter { [unowned self] _ in
                self.images.value.count == 6
            }
            .flatMap { [unowned self] _ in
                self.alert(title: "Limit reached", text: "To add more than 6 photos please purchase Collage Pro")
            }
            .sink { [unowned self] _ in
                self.navigationController?.popViewController(animated: true)
            } receiveValue: { _ in }
            .store(in: &subscriptions)

        
        newPhotos
            .map { [unowned self] newImage in
                return self.images.value + [newImage]
            }
            .subscribe(images)
            .store(in: &subscriptions)
        
        newPhotos
            .ignoreOutput()
            .delay(for: 2.0, scheduler: DispatchQueue.main)
            .sink { [unowned self] _ in
                self.updateUI(photos: self.images.value)
            } receiveValue: { _ in }
            .store(in: &subscriptions)

        navigationController!.pushViewController(photos, animated: true)
        
    }
    
    private func showMessage(_ title: String, description: String? = nil) {
        alert(title: title, text: description)
            .sink(receiveValue: { _ in })
            .store(in: &subscriptions)
    }
    
}
