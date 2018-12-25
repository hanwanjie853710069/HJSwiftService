//
//  HJLoginViewModel.swift
//  PerfectTemplate
//
//  Created by 韩小杰 on 2018/12/24.
//

import Foundation
import PerfectHTTP
import PerfectMySQL
import PerfectCRUD

/// 注册用户
///
/// - Parameters:
///   - request: 请求
///   - response: 响应
func registeredUsers(request: HTTPRequest, response: HTTPResponse) {
    let sql = MySQL()
    let connected = sql.connect(host: serveHost, user: serveUserName, password: dataPassword)
    guard connected else {
        try! response.setBody(json: ["code":Request_serverError_500.code,
                                     "msg":Request_serverError_500.msg,
                                     "result":[]
            ])
        
        response.completed()
        return
        
    }
    guard sql.selectDatabase(named: dataName) else {
        try! response.setBody(json: ["code":Request_serverError_500.code,
                                     "msg":Request_serverError_500.msg,
                                     "result":[]
            ])
        
        response.completed()
        return
    }
    
    defer { sql.close() }
    
    let databaseConfiguration = MySQLDatabaseConfiguration(connection: sql)
    let db = Database(configuration: databaseConfiguration)
    
    let email = request.param(name: "email") ?? ""
    let code = request.param(name: "code") ?? ""
    let name = request.param(name: "name") ?? ""
    let passWord = request.param(name: "passWord") ?? ""
    
    
    /** 校验验证码是否正确 */
    if code.isEmpty {
        try! response.setBody(json: ["code":User_codeError_1001.code,
                                     "msg":User_codeError_1001.msg,
                                     "result":[]
            ])
        
        response.completed()
        return
    }
    
    let userTable = db.table(User.self)
    
    /** 校验用户是否注册过 */
    do {
        let query = try userTable
            .order(by: \.email)
            .where(\User.email == email)
            .select()
        
        for user in query {
            print(user.email)
            try! response.setBody(json: ["code":User_alreadyExistsError_1000.code,
                                         "msg":User_alreadyExistsError_1000.msg,
                                         "result":[]
                ])
            response.completed()
            return
        }
    } catch {
        print("查询错误")
        try! response.setBody(json: ["code":Request_serverError_500.code,
                                     "msg":Request_serverError_500.msg,
                                     "result":[]
            ])
        response.completed()
        return
        
    }
    
    var userId = ""
    for _ in 0...7 {
        let arcCode = Int(arc4random() % 10)
        userId = userId + "\(arcCode)"
    }
    
    do {
        try userTable.insert([User.init(userId: userId, email: email, name: name, passWord: passWord, address: "未知", sex: "未知")])
    } catch {
        response.status = HTTPResponseStatus.custom(code: 500, message: "服务器异常")
        print("插入失败")
    }
    try! response.setBody(json: ["code":Request_successful_200.code,
                                 "msg":Request_successful_200.msg,
                                 "result":[]
        ])
    response.completed()
}

/// 登录接口
///
/// - Parameters:
///   - request: 请求
///   - response: 响应
func loginUsers(request: HTTPRequest, response: HTTPResponse) {
    let sql = MySQL()
    let connected = sql.connect(host: serveHost, user: serveUserName, password: dataPassword)
    guard connected else {
        try! response.setBody(json: ["code":Request_serverError_500.code,
                                     "msg":Request_serverError_500.msg,
                                     "result":[]
            ])
        
        response.completed()
        return
        
    }
    guard sql.selectDatabase(named: dataName) else {
        try! response.setBody(json: ["code":Request_serverError_500.code,
                                     "msg":Request_serverError_500.msg,
                                     "result":[]
            ])
        
        response.completed()
        return
    }
    
    defer { sql.close() }
    
    let databaseConfiguration = MySQLDatabaseConfiguration(connection: sql)
    let db = Database(configuration: databaseConfiguration)
    
    let email = request.param(name: "email") ?? ""
    let passWord = request.param(name: "passWord") ?? ""
    
    let userTable = db.table(User.self)
    /** 查询对应用户的密码 */
    do {
        let query = try userTable
            .order(by: \.email)
            .where(\User.email == email)
            .select()
        let usernull =  query.first { (user) -> Bool in
            return user.email == email
        }
        
        /** 校验用户是否存在 */
        guard let user = usernull   else {
            try! response.setBody(json: ["code":User_emailNoError_1003.code,
                                         "msg":User_emailNoError_1003.msg,
                                         "result":[]
                ])
            response.completed()
            return
        }
        
        /** 校验密码是否正确 */
        let result = user.passWord.compare(passWord)
        if result != .orderedSame {
            try! response.setBody(json: ["code":User_passWordError_1002.code,
                                         "msg":User_passWordError_1002.msg,
                                         "result":[]
                ])
            response.completed()
            return
        }
        
        /** 成功返回数据 */
        
        try! response.setBody(json: ["code":Request_successful_200.code,
                                     "msg":Request_successful_200.msg,
                                     "result":["email":user.email,
                                               "userId":user.userId,
                                               "name":user.name,
                                               "address":user.address,
                                               "sex":user.sex]
            ])
        response.completed()
    
    } catch {
        print("查询错误")
        try! response.setBody(json: ["code":Request_serverError_500.code,
                                     "msg":Request_serverError_500.msg,
                                     "result":[]
            ])
        response.completed()
        return
        
    }
    
}
