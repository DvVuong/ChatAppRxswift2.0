//
//  ImageService.swift
//  ChatAppDemo
//
//  Created by BeeTech on 08/12/2022.
//

import UIKit

open class ImageService: NSObject {
    static var share = ImageService()
    private  var cache = NSCache<NSString, UIImage>()
    
    func fetchImage(with url: String, completion: @escaping (UIImage) -> Void) {
        let keyCache = NSString(string: url)
        if let image = cache.object(forKey: keyCache)  {
            completion(image)
            return
        }
        guard let url = URL(string: url) else { return }
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if error != nil { return}
            guard let data = data, let image = UIImage(data: data) else { return }
            self.cache.setObject(image, forKey: keyCache)
            completion(image)
        }
        task.resume()
    }
    
    // MARK: ZoomImage
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    
    //MARK: Zom Image
    func zoomImage(_ image: UIImageView) {
        startingFrame = image.convert(image.frame, to: nil)
        // Tạo một màn hình mới cho việc zoom ảnh
        let zoomingImageView = UIImageView(frame: startingFrame!)
        //Esscap zoominImage
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlelEscapeZoomImage(_:))))
        zoomingImageView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(handleScaleImage(_:))))
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.image = image.image
        let window = UIApplication.shared.windows.first  { $0.isKeyWindow }
        blackBackgroundView = UIView(frame: window!.frame)
        blackBackgroundView?.backgroundColor = .white
        blackBackgroundView?.alpha = 0
        window?.addSubview(blackBackgroundView!)
        window?.addSubview(zoomingImageView)
        UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut, animations: {
            self.blackBackgroundView?.alpha = 1
            zoomingImageView.frame = CGRect(x: 0, y: 0, width: window!.frame.width, height: window!.frame.height)
            zoomingImageView.contentMode = .scaleAspectFit
            
        }, completion: nil)
    }
    
    @objc private func handlelEscapeZoomImage(_ tapGesture: UITapGestureRecognizer) {
        if let zoomOutImage = tapGesture.view {
            UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut) {
                zoomOutImage.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
            } completion: { (complete: Bool) in
                zoomOutImage.removeFromSuperview()
            }
            
        }
    }
    
    @objc private func handleScaleImage(_ pinch: UIPinchGestureRecognizer) {
        if let view = pinch.view {
            let x = pinch.scale
            let y = pinch.scale
            view.transform = view.transform.scaledBy(x: x, y: y)
            pinch.scale = 1
        }
    }
    
}
