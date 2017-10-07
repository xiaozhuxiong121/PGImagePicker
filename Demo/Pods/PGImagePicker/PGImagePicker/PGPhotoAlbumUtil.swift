//
//  PGPhotoAlbumUtil.swift
//  PGImagePicker
//
//  Created by piggybear on 2017/10/6.
//  Copyright © 2017年 piggybear. All rights reserved.
//

import Foundation
import Photos

enum PGPhotoAlbumResult {
    case success, error, denied
}

class PGPhotoAlbumUtil {
    class func isAuthorized() -> Bool {
        return PHPhotoLibrary.authorizationStatus() == .authorized || PHPhotoLibrary.authorizationStatus() == .notDetermined
    }
    
    class func saveImageInAlbum(image: UIImage, albumName: String = "", completion: ((_ result: PGPhotoAlbumResult) -> ())?) {
        if !isAuthorized() {
            completion?(.denied)
            return
        }
        var assetAlbum: PHAssetCollection?
        if albumName.isEmpty {
            let list = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
            assetAlbum = list[0]
        } else {
            let list = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
            list.enumerateObjects({ (album, index, stop) in
                let assetCollection = album
                if albumName == assetCollection.localizedTitle {
                    assetAlbum = assetCollection
                    stop.initialize(to: true)
                }
            })
            if assetAlbum == nil {
                PHPhotoLibrary.shared().performChanges({
                    PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
                }, completionHandler: { (isSuccess, error) in
                    self.saveImageInAlbum(image: image, albumName: albumName, completion: completion)
                })
                return
            }
        }
        
        PHPhotoLibrary.shared().performChanges({
            let result = PHAssetChangeRequest.creationRequestForAsset(from: image)
            if !albumName.isEmpty {
                let assetPlaceholder = result.placeholderForCreatedAsset
                let albumChangeRequset = PHAssetCollectionChangeRequest(for: assetAlbum!)
                albumChangeRequset!.addAssets([assetPlaceholder!]  as NSArray)
            }
        }) { (isSuccess: Bool, error: Error?) in
            if isSuccess {
                completion?(.success)
            } else{
                print(error!.localizedDescription)
                completion?(.error)
            }
        }
    }
}
