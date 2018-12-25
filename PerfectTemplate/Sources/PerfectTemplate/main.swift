//
//  main.swift
//  PerfectTemplate
//
//  Created by Kyle Jessup on 2015-11-05.
//	Copyright (C) 2015 PerfectlySoft, Inc.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2015 - 2016 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//

import PerfectHTTP
import PerfectHTTPServer
import PerfectMySQL

/** 声明路由 */
var routes = Routes()

routes.add(method: .get, uri: "/", handler: handler)

routes.add(method: .get, uri: "/get", handler: gethandlerAdd)

routes.add(method: .post, uri: "/post", handler: posthandlerAdd)

routes.add(method: .get, uri: "/**",
           handler: StaticFileHandler(documentRoot: "./webroot",
                                      allowResponseFilters: true).handleRequest)

/** 登录 */

/** 注册用户 */
routes.add(method: .post, uri: "/user/registered", handler: registeredUsers)
/** 登录用户 */
routes.add(method: .post, uri: "/user/loginUsers", handler: loginUsers)

/** 留言板 */

/** 发布留言 */
routes.add(method: .post, uri: "/messageBoard/postMessage", handler: postMessage)
/** 获取留言 */
routes.add(method: .get, uri: "/messageBoard/getMessage", handler: getMessage)

/** 连接服务器 */
try HTTPServer.launch(name: "localhost",
                      port: 8182,
                      routes: routes,
                      responseFilters: [
                        (PerfectHTTPServer.HTTPFilter.contentCompression(data: [:]), HTTPFilterPriority.high)])

