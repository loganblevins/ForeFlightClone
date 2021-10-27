//
//  UINavigationViewController+.swift
//  ForeFlightClone
//
//  Created by Logan Blevins on 9/23/21.
//

import Foundation
import UIKit

// Nav controllers are tricky. If we want to restrict orientation within
// the nav controller, we must tell the nav controller about the top most preference
// to make it effective.
extension UINavigationController {
    open override var shouldAutorotate: Bool {
        return visibleViewController?.shouldAutorotate ?? super.shouldAutorotate
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return visibleViewController?.supportedInterfaceOrientations ?? super.supportedInterfaceOrientations
    }
}
