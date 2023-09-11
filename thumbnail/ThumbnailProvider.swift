//
//  ThumbnailProvider.swift
//  thumbnail
//
//  Created by bb on 10.09.23.
//

import QuickLookThumbnailing
import ZIPFoundation

class ThumbnailProvider: QLThumbnailProvider {
    
    override func provideThumbnail(for request: QLFileThumbnailRequest, _ handler: @escaping (QLThumbnailReply?, Error?) -> Void) {
        
        // There are three ways to provide a thumbnail through a QLThumbnailReply. Only one of them should be used.
        
        
        // First way: Draw the thumbnail into the current context, set up with UIKit's coordinate system.
//        handler(QLThumbnailReply(contextSize: request.maximumSize, currentContextDrawing: { () -> Bool in
//            // Draw the thumbnail here.
//
//            // Return true if the thumbnail was successfully drawn inside this block.
//            return true
//        }), nil)
        
        
        print("zeug", request.fileURL)
        
        
        guard let archive = Archive(url: request.fileURL, accessMode: .read) else  {
            return
        }
        
        var isJPEG = false
        var raw_entry:Entry? = nil
        if archive["icon.png"] != nil {
            raw_entry = archive["icon.png"]
        } else if archive["icon.jpg"] != nil {
            raw_entry = archive["icon.jpg"]
            isJPEG = true
        }else if archive["icon.jpeg"] != nil {
            raw_entry = archive["icon.jpeg"]
            isJPEG = true
        } else {
            return
        }
        
        guard let entry = raw_entry else {
            print("no icon found in ", request.fileURL)
            return
        }
        
        var appIcon: CGImage? = nil
     
        do {
            var data = Data()
            try archive.extract(entry, skipCRC32: true, consumer: { (chunk) in
                print("zeug", chunk.count)
                data.append(chunk)
            })
            
            guard let provider = try data.withUnsafeBytes<CGDataProvider?>({ pointer in
                CGDataProvider(dataInfo: nil, data: pointer, size: data.count,releaseData: dataProviderReleaseCallback)
            }) else {return}
            
            
            if (!isJPEG) {
                appIcon = CGImage(pngDataProviderSource: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent)
                if (appIcon == nil) {
                    // maybe filename is wrong
                    appIcon = CGImage(jpegDataProviderSource: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent)
                }
            } else {
                appIcon = CGImage(jpegDataProviderSource: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent)
                if (appIcon == nil) {
                    // maybe filename is wrong
                    appIcon = CGImage(pngDataProviderSource: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent)
                }
            }
            
            
        } catch {
            print("Extracting entry from archive failed with error:\(error)")
            return
        }
        
        //                CGImage(pngDataProviderSource: <#T##CGDataProvider#>, decode: <#T##UnsafePointer<CGFloat>?#>, shouldInterpolate: <#T##Bool#>, intent: <#T##CGColorRenderingIntent#>)
        
        
        // Second way: Draw the thumbnail into a context passed to your block, set up with Core Graphics's coordinate system.
        handler(QLThumbnailReply(contextSize: request.maximumSize, drawing: { (context) -> Bool in
             
//            context.setFillColor(.black)
//            context.fill(CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: CGSize(width: request.maximumSize.width, height: request.maximumSize.height) ))
//
            guard let icon = appIcon else {return false}
            
            let icon_size = request.maximumSize.width
            
            let icon_rect = CGRect(origin: CGPoint(x: 0, y: request.maximumSize.height / 2.0), size: CGSize(width:icon_size, height:icon_size))
            
            context.draw(icon, in: icon_rect)
            
            // todo maybe draw app name below icon?
            
            return true
        }), nil)
         
        // Third way: Set an image file URL.
//        handler(QLThumbnailReply(imageFileURL: Bundle.main.url(forResource: "fileThumbnail", withExtension: "jpg")!), nil)
//
        
    }
}

    func dataProviderReleaseCallback(_ context:UnsafeMutableRawPointer?, data:UnsafeRawPointer, size:Int) {
        //data.deallocate()
    }
