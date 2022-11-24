//
//  PhotoWriter.swift
//  Collage
//
//  Created by ming on 2022/11/24.
//

import UIKit
import Foundation
import Photos
import Combine

class PhotoWriter {
    enum Error: Swift.Error {
        case couldNotSavePhoto
        case generic(Swift.Error)
    }
}
