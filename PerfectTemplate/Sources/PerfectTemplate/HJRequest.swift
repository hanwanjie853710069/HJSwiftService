//
//  HJRequest.swift
//  PerfectTemplate
//
//  Created by 韩小杰 on 2018/12/20.
//

import Foundation
import PerfectHTTP
import PerfectMySQL

/** 官方案例 */
func handler(request: HTTPRequest, response: HTTPResponse) {
    response.setHeader(.contentType, value: "application/json")
    
    let path = request.path
    
    print(path)
    
    try! response.setBody(json: ["1":2])
    
    response.completed()
}

/** get请求 数据解析  返回值 */
/**
 queryParams  请求地址后面拼接的参数  get和post都会有
 postParams   post独有的Params  get没有
 params  取得是 queryParams 和 postParams的和
 */
func gethandlerAdd(request: HTTPRequest, response: HTTPResponse) {
    
    response.setHeader(.contentType, value: "application/json")
    
    let path = request.path
    
    let dict = request.params();
    
    
    //    request.queryParams   文档推荐次参数
    //     request.param(name: "name")
    
    dict.forEach {
        
        let name = $0.0
        let type = $0.1
        print(name)
        print(type)
    }
    
    
    for ddd in dict {
        print(ddd.0)
        print(ddd.1)
    }
    
    print(path,dict)
    
    try! response.setBody(json: ["1":200,
                                 "2":200,
                                 "13":200,
                                 "14":200,
                                 "15":200,
                                 "16":200
        ])
    
    response.completed()
}

/** post请求 数据解析  返回值 */
/**
 queryParams  请求地址后面拼接的参数  get和post都会有
 postParams   post独有的Params  get没有
 params  取得是 queryParams 和 postParams的和
 */
func posthandlerAdd(request: HTTPRequest, response: HTTPResponse) {
    
    response.setHeader(.contentType, value: "application/json")
    
    let path = request.path
    
    let dict = request.params();
    
    //    request.queryParams   文档推荐
    //     request.param(name: "name")
    
    dict.forEach {
        
        let name = $0.0
        let type = $0.1
        print(name)
        print(type)
        
    }
    
    
    for ddd in dict {
        print(ddd.0)
        print(ddd.1)
    }
    
    print(path,dict)
    
    try! response.setBody(json: ["1":200,
                                 "2":200,
                                 "13":200,
                                 "14":200,
                                 "15":200,
                                 "16":200
        ])
    
    response.completed()
    
    fetchData()
}


/** 连接数据库 */
func fetchData() {
    
    let testHost = "localhost"
    let testUser = "root"
    let testPassword = "11111111"
    let testDB = "hanwanjie"
    
    /** 创建一个MySQL连接实例 */
    let dataMysql = MySQL()
    
    /** 连接数据库 */
    let connected = dataMysql.connect(host: testHost, user: testUser, password: testPassword)
    
    /** 连接数据库是否成功 */
    guard connected else {
        print(dataMysql.errorMessage())
        return
    }
    
    /** 关闭数据库 */
    defer {
        dataMysql.close()
    }
    
    selectDatabase(sql: dataMysql, name: testDB)
    
    queryData(sql: dataMysql, name: "persion")
    
}

/** 创建数据库 */
@discardableResult
func createDatabase(sql:MySQL, name:String) ->Bool {
    /** 创建数据库 */
    let creatDB = "CREATE DATABASE " + name
    let retval = sql.query(statement: creatDB)
    if !retval {
        print("创建数据库失败")
        print(sql.errorCode())
        print(sql.errorMessage())
        return false
    }
    print("创建数据库成功")
    return true
}

/** 删除数据库 */
@discardableResult
func deleteDatabase(sql:MySQL, name:String) ->Bool {
    /** 删除数据库 */
    let creatDB = "DROP DATABASE \(name)"
    let retval = sql.query(statement: creatDB)
    if !retval {
        print("删除数据库失败")
        print(sql.errorCode())
        print(sql.errorMessage())
        return false
    }
    print("删除数据库成功")
    return true
}

/** 选择数据库 */
@discardableResult
func selectDatabase(sql:MySQL, name:String) -> Bool {
    /** 选择要使用哪个数据库 如果数据库不存在则报错 */
    guard sql.selectDatabase(named: name) else {
        print(sql.errorCode())
        print(sql.errorMessage())
        return false
    }
    return true
}

/** 创建表 */
@discardableResult
func createTable(sql:MySQL, name:String) ->Bool {
    /** 创建表 */
    let instruction = """
    CREATE TABLE IF NOT EXISTS \(name) (
    id VARCHAR(64) PRIMARY KEY NOT NULL,
    expiration INTEGER)
    """
    guard sql.query(statement: instruction) else {
        /** 创建失败 */
        print("创建表失败")
        print(sql.errorMessage())
        print(sql.errorCode())
        return false
    }
    print("创建表成功")
    return true
}

/** 删除表 */
@discardableResult
func deleteTable(sql:MySQL, name:String) ->Bool {
    /** 删除表 */
    let instruction = "DROP TABLE \(name)"
    guard sql.query(statement: instruction) else {
        /** 删除失败 */
        print("删除表失败")
        print(sql.errorMessage())
        print(sql.errorCode())
        return false
    }
    print("删除表成功")
    return true
}

/** 插入数据到表 */
@discardableResult
func insertData(sql:MySQL, name:String) ->Bool {
    
//    guard sql.query(statement: "set names utf8") else {
//        print("设置编码，防止中文乱码失败")
//        return false
//    }
    
    /** 设置编码，防止中文乱码失败 */
    sql.setOption(.MYSQL_SET_CHARSET_NAME, "utf8")
    
    let age = 100
    let nametemp = "张三"
    let page = 300
    
    /** 插入数据到表 */
    let instruction = "INSERT INTO \(name) (id, age, name, page) VALUES (2, \(age), '\(nametemp)', \(page));"
    guard sql.query(statement: instruction) else {
        /** 插入数据到表失败 */
        print("插入表数据失败")
        print(sql.errorMessage())
        print(sql.errorCode())
        return false
    }
    print("插入表数据成功")
    return true
}

/** 查询数据到表 */
@discardableResult
func queryData(sql:MySQL, name:String) ->Bool {
    
//    guard sql.query(statement: "set names utf8") else {
//        print("设置编码，防止中文乱码失败")
//        return false
//    }
    
    /** 设置编码，防止中文乱码失败 */
    sql.setOption(.MYSQL_SET_CHARSET_NAME, "utf8")

    /** 查询数据到表 */
    let instruction = "SELECT name, age, page FROM \(name);"
    guard sql.query(statement: instruction) else {
        /** 查询数据到表失败 */
        print("查询表数据失败")
        print(sql.errorMessage())
        print(sql.errorCode())
        return false
    }
    print("查询表数据成功")
    
    /** 查询结果 */
   
    guard let results = sql.storeResults() else {
        return true
    }

    /** 创建一个字典数组用于存储结果 */
     var ary = [[String:Any]]()
    
    results.forEachRow { (row) in
        /** 保存选项表的Name名称字段，应该是所在行的第一列，所以是row[0]. */
        print("3333")
        print(row)
        let dict = ["name":row[0] ?? "",
                    "age":row[1] ?? "",
                    "page":row[2] ?? ""]
        ary.append(dict)
    }
    
    return true
}

