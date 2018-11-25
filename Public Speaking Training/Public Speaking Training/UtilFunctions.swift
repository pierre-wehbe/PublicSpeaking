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

enum DateFormat {
    case YYYY_MM_DD
    case MM_DD_YYYY
    case YYYYMMDD_HHMMSS
    case HHMM
}

extension Date {
    static func getDate(date: Date, format: DateFormat) -> (String, String) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .month, .year, .hour, .minute, .second], from: date)
        if let day = components.day, let month = components.month, let year = components.year,
            let hours = components.hour, let minutes = components.minute, let seconds = components.second {
            
            if format == .YYYYMMDD_HHMMSS {
                return ("\(year)\((month < 10) ? "0\(month)" : month.description)\((day < 10) ? "0\(day)" : day.description)_\((hours < 10) ? "0\(hours)" : hours.description):\((minutes < 10) ? "0\(minutes)" : minutes.description):\((seconds < 10) ? "0\(seconds)" : seconds.description)","")
            }
            
            if format == .HHMM {
                return ("\((hours < 10) ? "0\(hours)" : hours.description):\((minutes < 10) ? "0\(minutes)" : minutes.description)","")
            }
        }
        return ("", "")
    }
}
