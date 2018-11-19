import Foundation
import UIKit

func stringFromTimeInterval(interval: TimeInterval) -> NSString {
    
    let ti = NSInteger(interval)
    
    let ms = Int((interval) * 1000)
    
    let seconds = ti % 60
    let minutes = (ti / 60) % 60
    let hours = (ti / 3600)
    
//    return NSString(format: "%0.2d:%0.2d:%0.2d.%0.3d",hours,minutes,seconds,ms)
    return NSString(format: "%0.2d:%0.2d",minutes,seconds)

}

func getSecondaryColor() -> UIColor {
    return UIColor(red: 235 / 255, green: 204 / 255, blue: 123 / 255, alpha: 1.0)
}
