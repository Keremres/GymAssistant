//
//  UINavigationController+EXT.swift
//  GymAssistant
//
//  Created by Kerem RESNENLİ on 8.11.2024.
//

import Foundation
import UIKit

// Extending UINavigationController and adding conformance to UIGestureRecognizerDelegate.
// This extension helps enable the swipe-to-go-back gesture, even when the back button is hidden.
extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
    // viewDidLoad is called when the UINavigationController's view is loaded.
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting the interactivePopGestureRecognizer's delegate to self.
        // This allows control over the swipe-to-go-back gesture behavior.
        interactivePopGestureRecognizer?.delegate = self
    }
    
    // gestureRecognizerShouldBegin is called before the swipe gesture begins.
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // This code returns true only if there’s more than one view controller in the stack,
        // allowing the swipe-to-go-back gesture only when there's a screen to go back to.
        return viewControllers.count > 1
    }
}
