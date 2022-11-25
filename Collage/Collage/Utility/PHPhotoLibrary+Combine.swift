//
//  PHPhotoLibrary+Combine.swift
//  Collage
//
//  Created by ming on 2022/11/24.
//

import Foundation
import Photos
import Combine

extension PHPhotoLibrary {
    
    static var isAuthorized: Future<Bool, Never> {
        return Future { resolve in
            self.fetchAuthorizationStatus { status in
                resolve(.success(status))
            }
        }
    }
    
    static func fetchAuthorizationStatus(callback: @escaping (Bool) -> Void) {
        
        let currentlyAuthorized = authorizationStatus() == .authorized
        
        guard !currentlyAuthorized else {
            return callback(currentlyAuthorized)
        }
        
        requestAuthorization { newStatus in
            callback(newStatus == .authorized)
        }
        
    }
}
