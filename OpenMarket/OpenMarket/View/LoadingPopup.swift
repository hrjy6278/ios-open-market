//
//  LoadingPopup.swift
//  OpenMarket
//
//  Created by Do Yi Lee on 2021/08/20.
//

import UIKit

class Loading: NSObject {
    static let sharedInstance = Loading()
    private var popupView: UIImageView?
    
    private override init() {
    }
   
    class func hide() {
        if let popupView = sharedInstance.popupView {
                popupView.stopAnimating()
                popupView.removeFromSuperview()
            }
    }
    
    class func show() {
        let popupView = UIImageView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        popupView.backgroundColor = .red
        popupView.animationImages = Loading.getAnimationImageArray()
        popupView.animationDuration = 4.0
        popupView.animationRepeatCount = 0
        
        if let window = UIApplication.shared.keyWindow {
            window.addSubview(popupView)
            popupView.startAnimating()
//            sharedInstance.popupView?.removeFromSuperview()
            sharedInstance.popupView = popupView
        }
    }
    
    private class func getAnimationImageArray() -> [UIImage] {
            var animationArray: [UIImage] = []
            animationArray.append(UIImage(named: "1")!)
            animationArray.append(UIImage(named: "2")!)
            animationArray.append(UIImage(named: "3")!)
            animationArray.append(UIImage(named: "4")!)

            return animationArray
        }
}
