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
