//
//  HJTableModel.swift
//  PerfectTemplate
//
//  Created by 韩小杰 on 2018/12/24.
//

import Foundation

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
