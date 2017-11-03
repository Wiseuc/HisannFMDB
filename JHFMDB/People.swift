//
//  People.swift
//  JHFMDB
//
//  Created by JH on 2017/11/1.
//  Copyright © 2017年 JH. All rights reserved.
//

import UIKit

class People: NSObject, NSCopying {


    var name:String  = ""
    var age:Int      = 0
    var height:Float = 0.0
    var isMan = false
    var data1:Data = Data()
    var num:NSNumber = 0
    
    
    
    ///实现copyWithZone方法
    func copy(with zone: NSZone? = nil) -> Any {
        let p = People.init()
        p.name = self.name
        p.age = self.age
        p.height = self.height
        p.isMan = self.isMan
        p.data1 = self.data1
        p.num = self.num
        return p
    }
    
 
    
}
