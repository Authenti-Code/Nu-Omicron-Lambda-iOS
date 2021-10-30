//
//  Utility.swift
//  NewProject
//
//  Created by Jatinder Arora on 29/10/19.
//  Copyright © 2019 osx. All rights reserved.
//

import Foundation
import UIKit
class  Utility {
    
    static func fromDateToString(dt: Date) -> String{
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date / server String
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        let myString = formatter.string(from: dt) // string purpose I add here
        // convert your string to date
        let yourDate = formatter.date(from: myString)
        //then again set the date format whhich type of output you need
        formatter.dateFormat = "MM/dd/yy h:mm a"
        // again convert your date to string
        let myStringafd = formatter.string(from: yourDate!)

        print(myStringafd)
        return myStringafd
    }
    static func fromDateToString1(dt: Date) -> String{
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date / server String
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        let myString = formatter.string(from: dt) // string purpose I add here
        // convert your string to date
        let yourDate = formatter.date(from: myString)
        //then again set the date format whhich type of output you need
        formatter.dateFormat = "MM/dd/yy h:mm a"
        // again convert your date to string
        let myStringafd = formatter.string(from: yourDate!)

        print(myStringafd)
        return myStringafd
    }
    static func formatTime(str: String) -> String{
        let dateAsString = str
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        let date = dateFormatter.date(from: dateAsString)
        dateFormatter.dateFormat = "h:mm a"
        let Date12 = dateFormatter.string(from: date!)
        return Date12
    }
    static func formatTimeNew(str: String) -> String{
        // create dateFormatter with UTC time format
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        let date = dateFormatter.date(from: str)// create   date from string
        
        // change to a readable time format and change to local time zone
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.timeZone = NSTimeZone.local
        let timeStamp = dateFormatter.string(from: date!)
        
        return timeStamp
    }
   static func heightForLabel(text:String, font:UIFont, width:CGFloat) -> CGFloat
    {
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
        
    }
    static func formatDate(date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        let date = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "MMMM dd,yyyy"
        return  dateFormatter.string(from: date!)
    }
    static func formatDateMessage(date: String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        let date = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "MMMM dd,yyyy"
        return  dateFormatter.string(from: date!)
    }
    static func convertToDate(str :String) -> Date{
        let isoDate = str
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        let date = dateFormatter.date(from:isoDate)!
        
        return date
    }
    
    
}
