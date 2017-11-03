//
//  HisannFMDB.swift
//  JHFMDB
//
//  Created by JH on 2017/11/2.
//  Copyright © 2017年 JH. All rights reserved.
//

import UIKit
fileprivate let kNUMTYPE_STRING        = "string"
fileprivate let kNUMTYPE_NUMBER        = "number"
fileprivate let kNUMTYPE_DATA          = "data"
fileprivate let kNUMTYPE_BOOL          = "bool"
fileprivate let kNUMTYPE_FLOAT_DOUBLE  = "float & double"
fileprivate let kNUMTYPE_INTEGER       = "integer"

fileprivate let kUNSAFEPOINTERTYPE_STRING        = "T@\"NSString\""
fileprivate let kUNSAFEPOINTERTYPE_NUMBER        = "T@\"NSNumber\""
fileprivate let kUNSAFEPOINTERTYPE_DATA          = "T@\"NSData\""
fileprivate let kUNSAFEPOINTERTYPE_BOOL          = "Tc"
fileprivate let kUNSAFEPOINTERTYPE_FLOAT_DOUBLE  = "Tf"
fileprivate let kUNSAFEPOINTERTYPE_INTEGER       = "Ti"


class HisannFMDB: NSObject {
    static let `default` = HisannFMDB()
    
    lazy var dbPath: String = {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/wiseucDB.db"
        return path
    }()
    
    lazy var queue: FMDatabaseQueue = {
        let db = FMDatabaseQueue.init(path: self.dbPath)
        return db!
    }()
    
    override init() {
        super.init()
        self.openDB()
        
        queue.inDatabase { (db) in
            if !db.isOpen {
                print("/*** HISANN: DB OPEN FAILED ***/")
            }
        }
    }
}










// MARK: ======================about 表操作=============================

extension HisannFMDB {
    
    /// 是否存在表
    ///
    /// - Parameter tablename: 表名
    /// - Returns:
    func hisann_isTableExists(tablename:String) -> Bool {
        var flag = false
        queue.inTransaction { (db, rollback) in
            flag = db.tableExists(tablename)
        }
        return flag
    }
    
    
    /// 创建表
    ///
    /// - Parameters:
    ///   - tablename: 表名
    ///   - model: 对象
    func hisann_createTable(tablename:String,model:AnyObject)
    {
        let properties = self.model2properties(cls: model.classForCoder)
        let propertyDict = self.model2Dictionary(cls: model.classForCoder)
        //let clomns:[String] = self.execute_qyery_columns(tablename: tablename)
        
        
        
        var sql = "create table if not exists \(tablename) ( id integer primary key autoincrement"
        
        /*
         for index in 0..<properties.count {
         sql.append(",\(properties[index]) varchar(256)")
         }
         */
        for name in properties
        {
            if let value = propertyDict[name] as? String {
                
                if value == kNUMTYPE_STRING
                {
                    sql.append(",\(name) varchar(256)")
                }
                else if value == kNUMTYPE_NUMBER || value == kNUMTYPE_INTEGER
                {
                    sql.append(",\(name) Integer")
                }
                else if value == kNUMTYPE_BOOL
                {
                    sql.append(",\(name) Bool")
                }
                else if value == kNUMTYPE_DATA
                {
                    sql.append(",\(name) Data")
                }
                else if value == kNUMTYPE_FLOAT_DOUBLE
                {
                    sql.append(",\(name) Double")
                }
            }
        }
        
        sql.append(")")
        print("/*** HISANN: \(sql) ***/")
        self.execute_createTable(sqlStr: sql)
    }
    
    
    
    /// 删除表
    ///
    /// - Parameter tablename: 表名
    func hisann_dropTable(tablename:String)
    {
        let sql = "drop table \(tablename)"
        print("/*** HISANN: \(sql) ***/")
        self.execute_dropTable(sqlStr: sql)
    }
    
    func hisann_updateTable() {
        
    }
    
    func hisann_queryTable() {
        
    }
    
    
}









// MARK: ======================about 数据操作=============================

extension HisannFMDB {
    
    /// 插入数据
    ///
    ///insert into T_people (name,age,height) values(?,?,?)
    func hisann_insert(tablename:String,model:AnyObject) {
        
        let properties: Array<String> = self.model2properties(cls: model.classForCoder)
        var sql = "insert into \(tablename) ("
        
        for index in 0..<properties.count {
            sql.append("\(properties[index])")
            if index != properties.count - 1 {
                sql.append(",")
            }
        }
        
        sql.append(") values(")
        for index in 0..<properties.count {
            sql.append("?")
            if index != properties.count - 1 {
                sql.append(",")
            }
        }
        sql.append(")")
        //print("/***  HISANN: \(sql)  ***/")
        
        //Arguments
        var arguments = [Any]()
        var argumentStr = ""
        
        for i in 0..<properties.count {
            let propertie = model.value(forKey: properties[i])
            if propertie != nil {
                arguments.append(propertie!)
                argumentStr = argumentStr + "\(propertie!)"
                
                if i != properties.count - 1 {
                    argumentStr = argumentStr + ","
                }
            }
        }
        print("/***  HISANN: \(sql)  (\(argumentStr)) ***/")
        self.execute_insert(sqlStr: sql, arguments: arguments)
    }
    
    /// 删除数据
    func hisann_delete() {
        
    }
    
    /// 更新数据
    func hisann_update() {
        
    }
    
    /// 查找数据(all)
    /// select (name,age,height) from T_people where age <= 25 and height = 180
    func hisann_query(tablename:String,
                      selectStr:String?,
                      whereStr:String?,
                      model:NSObject) -> [NSObject] {
        
        var sql = "select"
        
        if selectStr != nil {
            sql = sql + selectStr!
        }else{
            sql = sql + " * from "
        }
        
        sql = sql + tablename
        
        if whereStr != nil {
            sql = sql + whereStr!
        }
        
        print("/***  HISANN: \(sql)  ***/")
        
        
        //模型属性字典 key:value
        let propertyDict:Dictionary = self.model2Dictionary(cls: model.classForCoder)
        //数据库表所有字段
        let clomns:[String] = self.execute_qyery_columns(tablename: tablename)
        var results = Array<NSObject>()
        
        let set:FMResultSet? = self.execute_query(sqlStr: sql)
        if set != nil
        {
            while set!.next()
            {
                //copy
                let obj:NSObject = model.copy() as! NSObject
                
                for name in clomns
                {
                    if let value = propertyDict[name] as? String {
                        
                        if value == kNUMTYPE_STRING
                        {
                            let tmp = set!.string(forColumn: name)
                            if tmp != nil {
                                obj.setValue(tmp!, forKey: name)
                            }
                        }
                        else if value == kNUMTYPE_NUMBER || value == kNUMTYPE_INTEGER
                        {
                            let tmp = set!.int(forColumn: name)
                            obj.setValue(tmp, forKey: name)
                        }
                        else if value == kNUMTYPE_BOOL
                        {
                            let tmp = set!.bool(forColumn: name)
                            obj.setValue(tmp, forKey: name)
                        }
                        else if value == kNUMTYPE_DATA
                        {
                            let tmp = set!.data(forColumn: name)
                            if tmp != nil {
                                obj.setValue(tmp, forKey: name)
                            }
                        }
                        else if value == kNUMTYPE_FLOAT_DOUBLE
                        {
                            let tmp = set!.double(forColumn: name)
                            obj.setValue(tmp, forKey: name)
                        }
                        
                    }
                }
                results.append(obj)
            }
        }
        return results
    }
    
}













// MARK: ======================about Private=============================

extension HisannFMDB {
    
    
    /// 打开数据库
    fileprivate func openDB() {
        queue.inDatabase { (db) in
            db.open()
        }
    }
    
    
    /// 关闭数据库
    fileprivate func closeDB() {
        queue.inDatabase { (db) in
            db.close()
        }
    }
    
    
    /// 执行增加、删除、修改、创建表。。。
    fileprivate func execute(sqlStr:String) {
        queue.inTransaction { (db, rollback) in
            db.executeUpdate(sqlStr, withArgumentsIn: [])
        }
    }
    
    
    /// 创建表
    fileprivate func execute_createTable(sqlStr:String) {
        queue.inTransaction { (db, rollback) in
            db.executeUpdate(sqlStr, withArgumentsIn: [])
        }
    }
    
    /// 删除表
    fileprivate func execute_dropTable(sqlStr:String) {
        queue.inTransaction { (db, rollback) in
            db.executeUpdate(sqlStr, withArgumentsIn: [])
        }
    }
    
    
    
    /// 添加数据
    fileprivate func execute_insert(sqlStr:String,arguments:[Any]) {
        queue.inTransaction { (db, rollback) in
            db.executeUpdate(sqlStr, withArgumentsIn: arguments)
        }
    }
    
    /// 获取表字段
    fileprivate func execute_qyery_columns(tablename:String) -> [String] {
        
        var arrM = [String]()
        
        queue.inDatabase { (db) in
            
            let set:FMResultSet = db.getTableSchema(tablename)
            
            while set.next()
            {
                arrM.append(set.string(forColumn: "name")!)
            }
        }
        return arrM
    }
    
    
    
    
    /// 执行查询
    ///
    /// - Parameters:
    ///   - sqlStr: sql语句
    ///   - arguments: 参数
    ///  var sql:String = "select * from ImgInfo where FID = ?"
    fileprivate func execute_query(sqlStr:String) -> FMResultSet? {
        
        var set:FMResultSet?
        
        queue.inTransaction { (db, rollback) in
            
            set = db.executeQuery(sqlStr, withArgumentsIn: [])
        }
        return set
    }
    
    
    
    
    
    
    
    
    
    
    //属性列表
    dynamic fileprivate func model2properties(cls:AnyClass) -> Array<String> {
        var arr = Array<String>()
        var outCount:UInt32 = 0
        let properties = class_copyPropertyList(cls, &outCount)
        
        for index in 0..<outCount {
            if properties != nil {
                let property = properties![Int(index)]
                let name:UnsafePointer = property_getName(property) //属性
                //let type:UnsafePointer = property_getAttributes(property) //属性类型
                arr.append(String.init(cString: name))
            }
        }
        free(properties)
        return arr
    }
    
    
    
    // 成员列表 && 属性列表
    // 简单来说，成员变量就是带有下划线的，没有带下划线的就是属性。(_contentView就是成员变量,contentView就是属性)
    dynamic fileprivate func ivars(cls:AnyClass) -> Array<Any> {
        var arr = Array<Any>()
        var count: UInt32 = 0
        let ivars = class_copyIvarList(UITextView.self, &count)
        
        for i in 0 ..< count {
            let ivar = ivars![Int(i)]
            let name = ivar_getName(ivar)
            arr.append(name!)
            print(String(cString: name!))
        }
        free(ivars)
        return arr
    }
    
    
    /// 模型转字典
    fileprivate func model2Dictionary(cls:AnyClass) -> Dictionary<String, Any> {
        
        var dictM = [String:Any]()
        var outCount:UInt32 = 0
        let properties = class_copyPropertyList(cls, &outCount)
        
        for index in 0..<outCount {
            if properties != nil
            {
                let property = properties![Int(index)]
                let name:UnsafePointer = property_getName(property) //属性
                let type:UnsafePointer = property_getAttributes(property) //属性类型
                let type2 = self.autoConvertPropertType(unsafePointer: type)
                dictM.updateValue(type2, forKey: String.init(cString: name)) //value:属性类型  key:属性
                print("属性类型 name = \(String.init(cString: name))   type = \(type2)")
            }
        }
        return dictM
    }
    
    
    
    /// 属性类型转换
    
    fileprivate func autoConvertPropertType(unsafePointer:UnsafePointer<Int8>) -> String {
        
        var tempStr = String.init(cString: unsafePointer)
        
        if tempStr.contains("T@\"NSString\"") //kUNSAFEPOINTERTYPE_STRING
        {
            tempStr = kNUMTYPE_STRING
        }
        else if tempStr.hasPrefix("T@\"NSNumber\"")//kUNSAFEPOINTERTYPE_NUMBER
        {
            tempStr = kNUMTYPE_NUMBER
        }
        else if tempStr.hasPrefix("T@\"NSData\"")//kUNSAFEPOINTERTYPE_DATA
        {
            tempStr = kNUMTYPE_DATA
        }
        else if tempStr.hasPrefix("Ti") ||  //kUNSAFEPOINTERTYPE_INTEGER
            tempStr.hasPrefix("Ts") ||
            tempStr.hasPrefix("Tq") ||
            tempStr.hasPrefix("Tb")
        {
            tempStr = kNUMTYPE_INTEGER
        }
        else if tempStr.hasPrefix("Tf") ||  tempStr.hasPrefix("Td") //kUNSAFEPOINTERTYPE_FLOAT_DOUBLE
        {
            tempStr = kNUMTYPE_FLOAT_DOUBLE
        }
        else if tempStr.hasPrefix("Tc")//kUNSAFEPOINTERTYPE_BOOL
        {
            tempStr = kNUMTYPE_BOOL
        }
        return tempStr
    }
    
    
}

