//
//  HJTableModel.swift
//  PerfectTemplate
//
//  Created by 韩小杰 on 2018/12/24.
//

import Foundation

/** 用户表 */
struct User: Codable {
    /** 用户id */
    let userId: String
    /** 用户邮箱 */
    let email: String
    /** 用户name */
    let name: String
    /** 用户密码 */
    let passWord: String
    /** 用户地址 */
    let address: String
    /** 用户性别 */
    let sex: String
}

/** 留言板表 */
struct MessageBoard: Codable {
    /** 用户id */
    let userId: String
    /** 用户name */
    let name: String
    /** 用户地址 */
    let address: String
    /** 用户性别 */
    let sex: String
    /** 留言内容 */
    let content: String
    /** 留言id */
    let contentId: String
    /** 创建时间 */
    let creatTime: String
    /** 时间戳 */
    let timeStamp: Int
}
