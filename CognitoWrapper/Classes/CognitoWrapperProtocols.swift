//
//  CognitoWrapperProtocols.swift
//  CognitoWrapper
//
//  Created by Esteban Garro on 2018-12-10.
//

import Foundation
import EitherResult

public protocol CognitoLogger {
    func log(message:String)
    func log(error:Error)
}

public protocol CognitoUserCredentialsProvider {
    var username: String { get }
    var password: String { get }
}

public protocol CognitoBasicUserInfo : Codable {
    var firstName: String { get }
    var lastName: String { get }
    var userID: String { get }
    var isActive: Bool { get }
}

public protocol CognitoUserPoolProvider {
    var clientID: String { get }
    var poolID: String { get }
}

public struct LoginResponse<UserInfo: Decodable>: Decodable {
    public let authToken: String
    public let data: UserInfo
}

public protocol CognitoAuth {
    func login<T: Decodable>(with credentials: CognitoUserCredentialsProvider,
                                   completion: @escaping (ALResult<LoginResponse<T>>) -> Void)
    func logout()
}
