//
//  ViewController.swift
//  JHFMDB
//
//  Created by JH on 2017/11/1.
//  Copyright © 2017年 JH. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        /// 创建表
        let flag = HisannFMDB.default.hisann_isTableExists(tablename: "T_people")
        if flag {
            print("HISANN：存在表")
            print("HISANN：删除表")
            HisannFMDB.default.hisann_dropTable(tablename: "T_people")
        }
        print("HISANN：创建表")
        HisannFMDB.default.hisann_createTable(tablename: "T_people", model: People())
        
        
        
        
        
        /// 插入数据
        for i in 0..<10 {
            let p = People()
            p.name = "jianghai\(i)"
            p.age = 25
            p.height = 170.0
            p.isMan = true
            p.data1 = Data.init(count: 7)
            p.num = 99
            HisannFMDB.default.hisann_insert(tablename: "T_people", model: p)
        }
        
        
        
        
        
        
        /// 查询数据
        
        let arr = HisannFMDB.default.hisann_query(tablename: "T_people",
                                              selectStr: nil,
                                              whereStr: nil,
                                              model: People())
        
        if let arr2 = arr as? [People] {
            
            for item in arr2 {
                print(item.name)
                print(item.age)
                print(item.height)
                print(item.isMan)
                print(item.data1)
                print(item.num)
                print("=========================")
            }
        }
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

