//
//  HJErrorCode.swift
//  PerfectTemplate
//
//  Created by 韩小杰 on 2018/12/25.
//

import Foundation

/** 错误结构体 */
struct HJErrorStruct {
    let code: Int
    let msg: String
}
/** 通用错误码 */

/** 500 服务器异常 */
let Request_serverError_500 = HJErrorStruct.init(code: 500, msg: "服务器异常。")
/** 200 请求成功 */
let Request_successful_200 = HJErrorStruct.init(code: 200, msg: "请求成功。")


/** 登录 */

/** 注册 用户已存在 */
let User_alreadyExistsError_1000 = HJErrorStruct.init(code: 1000, msg: "该邮箱已注册，请登录。")
/** 注册 验证码错误 */
let User_codeError_1001 = HJErrorStruct.init(code: 1001, msg: "验证码错误。")

/** 登录 密码错误 */
let User_passWordError_1002 = HJErrorStruct.init(code: 1002, msg: "密码错误。")
/** 登录 该邮箱未注册错误 */
let User_emailNoError_1003 = HJErrorStruct.init(code: 1003, msg: "该邮箱未注册。")

/** 留言板 */

/** 登录 该用户不存在 */
let User_userNoError_1004 = HJErrorStruct.init(code: 1004, msg: "该用户不存在。")
