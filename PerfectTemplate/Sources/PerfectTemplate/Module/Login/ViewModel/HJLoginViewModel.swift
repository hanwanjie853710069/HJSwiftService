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

/** 配置mysql */
func mySqlConfiguration(mySql:MySQL, request: HTTPRequest, response: HTTPResponse) -> Bool  {
    
    let connected = mySql.connect(host: serveHost, user: serveUserName, password: dataPassword)
    guard connected else {
        try! response.setBody(json: ["code":Request_serverError_500.code,
                                     "msg":Request_serverError_500.msg,
                                     "result":[]
            ])
        
        response.completed()
        return false
        
    }
    guard mySql.selectDatabase(named: dataName) else {
        try! response.setBody(json: ["code":Request_serverError_500.code,
                                     "msg":Request_serverError_500.msg,
                                     "result":[]
            ])
        
        response.completed()
        return false
    }
    
    return true
}

/** 配置dataBase */
func databaseConfiguration(mySql:MySQL) -> Database<MySQLDatabaseConfiguration> {
    let databaseConfiguration = MySQLDatabaseConfiguration(connection: mySql)
    let db = Database(configuration: databaseConfiguration)
    
    return db
}

/// 注册用户
///
/// - Parameters:
///   - request: 请求
///   - response: 响应
func registeredUsers(request: HTTPRequest, response: HTTPResponse) {
    let mySql = MySQL()
    if !mySqlConfiguration(mySql:mySql, request: request, response: response) { return }
    defer { mySql.close() }
    
    let db = databaseConfiguration(mySql:mySql)

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
    let mySql = MySQL()
    if !mySqlConfiguration(mySql:mySql, request: request, response: response) { return }
    defer { mySql.close() }
    
    let db = databaseConfiguration(mySql:mySql)

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


/// 发布留言
///
/// - Parameters:
///   - request: 请求
///   - response: 响应
func postMessage(request: HTTPRequest, response: HTTPResponse) {
    let mySql = MySQL()
    if !mySqlConfiguration(mySql:mySql, request: request, response: response) { return }
    defer { mySql.close() }
    
    let db = databaseConfiguration(mySql:mySql)

    let content = request.param(name: "content") ?? ""
    let userId = request.param(name: "userId") ?? ""

    let userTable = db.table(User.self)
    /** 查询对应用户的密码 */
    do {
        let query = try userTable
            .order(by: \.userId)
            .where(\User.userId == userId)
            .select()
        let usernull =  query.first { (user) -> Bool in
            return user.userId == userId
        }

        /** 校验用户是否存在 */
        guard let user = usernull   else {
            try! response.setBody(json: ["code":User_userNoError_1004.code,
                                         "msg":User_userNoError_1004.msg,
                                         "result":[]
                ])
            response.completed()
            return
        }


        let messageTable = db.table(MessageBoard.self)

        var messageId = ""
        for _ in 0...9 {
            let arcCode = Int(arc4random() % 10)
            messageId = messageId + "\(arcCode)"
        }

        //获取当前时间
        let now = Date()

        // 创建一个日期格式器
        let dformatter = DateFormatter()
        dformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        print("当前日期时间：\(dformatter.string(from: now))")
        let time = dformatter.string(from: now)

        //当前时间的时间戳
        let timeInterval:TimeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        print("当前时间的时间戳：\(timeStamp)")

        do {
            try messageTable.insert([MessageBoard.init(userId: user.userId, name: user.name, address: user.address, sex: user.sex, content: content, contentId: messageId, creatTime:time, timeStamp:timeStamp)])
        } catch {
            response.status = HTTPResponseStatus.custom(code: 500, message: "服务器异常")
            print(error)
            print("插入失败")
        }

        /** 发布留言成功 */
        try! response.setBody(json: ["code":Request_successful_200.code,
                                     "msg":postSuccessful,
                                     "result":[]
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


/// 获取留言
///
/// - Parameters:
///   - request: 请求
///   - response: 响应
func getMessage(request: HTTPRequest, response: HTTPResponse) {
   let mySql = MySQL()
    if !mySqlConfiguration(mySql:mySql, request: request, response: response) { return }
    defer { mySql.close() }
    
    let db = databaseConfiguration(mySql:mySql)
    
    let messageTable = db.table(MessageBoard.self)
    
    let size = request.param(name: "size") ?? ""
    let page = request.param(name: "page") ?? ""

    let skip = (Int(size) ?? 0) * ((Int(page) ?? 0) - 1)
    
    do {
        let query = try messageTable
            .order(descending: \MessageBoard.timeStamp)
            .limit((Int(size) ?? 0), skip: skip)
            .select()
    
        var array:[[String : String]] = [[String : String]]()
        
        for message in query {
            let dict:[String : String] = ["name":message.name,
                                          "content":message.content,
                                          "address":message.address,
                                          "sex":message.sex,
                                          "contentId":message.contentId,
                                          "creatTime":message.creatTime,
                                          ]
            array.append(dict)
        }
        
        /** 获取留言成功 */
        try! response.setBody(json: ["code":Request_successful_200.code,
                                     "msg":Request_successful_200.msg,
                                     "result":array
            ])
        response.completed()
        
    } catch {
        try! response.setBody(json: ["code":Request_serverError_500.code,
                                     "msg":Request_serverError_500.msg,
                                     "result":[]
            ])
        response.completed()
        return
    }
    
}


/// 更新用户信息
///
/// - Parameters:
///   - request: 请求体
///   - response: 返回体
func updateUserMessage(request: HTTPRequest, response: HTTPResponse) {
    let mySql = MySQL()
    if !mySqlConfiguration(mySql:mySql, request: request, response: response) { return }
    defer { mySql.close() }
    
    let db = databaseConfiguration(mySql:mySql)

    let sex = request.param(name: "sex") ?? ""
    let name = request.param(name: "name") ?? ""
    let address = request.param(name: "address") ?? ""
    let userid = request.param(name: "userId") ?? ""
    let new = User.init(userId: "", email: "1111", name: name, passWord: "", address: address, sex: sex)
    
    var temp = \User.sex
    if !name.isEmpty {
        temp = \User.name
    }
    if !address.isEmpty {
        temp = \User.address
    }

    do {

      let _ =  try db.transaction {

            try db.table(User.self)
                .where(\User.userId == userid)
                .update(new, setKeys: temp,\User.email)
        
        }
        /** 成功 */
        try! response.setBody(json: ["code":Request_successful_200.code,
                                     "msg":Request_successful_200.msg,
                                     "result":[]
            ])
        response.completed()

    } catch {
        
        /** 保存用户信息失败 */
        try! response.setBody(json: ["code":User_saveMessageError_1005.code,
                                     "msg":User_saveMessageError_1005.msg,
                                     "result":[]
            ])
        response.completed()
    }
}

/// 获取用户信息
///
/// - Parameters:
///   - request: 请求体
///   - response: 返回体
func getUserMessage(request: HTTPRequest, response: HTTPResponse) {
//    let mySql = MySQL()
//    if !mySqlConfiguration(mySql:mySql, request: request, response: response) { return }
//    defer { mySql.close() }
    
//    let db = databaseConfiguration(mySql:mySql)
    
    do {
     let db = Database(configuration: try MySQLDatabaseConfiguration(database: dataName, host:serveHost , username: serveUserName, password: dataPassword))
        
        let userId = request.param(name: "userId") ?? ""
        let userTable = db.table(User.self)
        
        let query = try userTable
            .order(by: \.userId)
            .where(\User.userId == userId)
            .select()
        
        let usernull =  query.first { (user) -> Bool in
            return user.userId == userId
        }
        
        /** 校验用户是否存在 */
        guard let user = usernull else {
            try! response.setBody(json: ["code":User_emailNoError_1003.code,
                                         "msg":User_emailNoError_1003.msg,
                                         "result":[]
                ])
            response.completed()
            return
        }
        
        /** 成功返回数据 */
        try response.setBody(json: ["code":Request_successful_200.code,
                                     "msg":Request_successful_200.msg,
                                     "result":["email":user.email,
                                               "userId":user.userId,
                                               "name":user.name,
                                               "address":user.address,
                                               "sex":user.sex]
            ])
        response.completed()
        
    } catch  {
        try! response.setBody(json: ["code":Request_serverError_500.code,
                                     "msg":Request_serverError_500.msg,
                                     "result":[]
            ])
        response.completed()
        return
        
    }
    
}
