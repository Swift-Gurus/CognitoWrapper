//
//  CognitoWrapper.swift
//  mFind
//
//  Created by Alex Hmelevski on 2018-03-30.
//  Copyright © 2018 Aldo Group Inc. All rights reserved.
//

import Foundation
import AWSCognitoAuth
import AWSCognito
import AWSUserPoolsSignIn
import EitherResult

public enum CognitoLoginError : Error {
    case UsernameNotFound
}


public final class DefaultMemoryCredentialStorage: CredentialsStorage {
    public static var sharedInstance = DefaultMemoryCredentialStorage()
    public var lastLoginCredentials: UserCredentials?
}

public protocol CredentialsStorage {
    var lastLoginCredentials: UserCredentials? { get set }
}

/**
 Class to hide Cognito API from the client
 **/
final public class CognitoWrapper: NSObject, CognitoAuth {
    
    var pool: AWSCognitoIdentityUserPool
    public var credentialsStorage: CredentialsStorage
    private let logger: CognitoLogger?
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    
    public init(userPool: CognitoUserPoolProvider,
                credentialsStorage: CredentialsStorage = DefaultMemoryCredentialStorage.sharedInstance,
                logger: CognitoLogger? = nil) {
        self.logger = logger
        self.credentialsStorage = credentialsStorage
        let configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: nil)
        let poolConf  = AWSCognitoIdentityUserPoolConfiguration(clientId: userPool.clientID,
                                                                clientSecret: nil,
                                                                poolId: userPool.poolID)
        
        AWSCognitoIdentityUserPool.register(with: configuration,
                                            userPoolConfiguration: poolConf,
                                            forKey: "CognitoUserPool")
        
        pool = AWSCognitoIdentityUserPool(forKey: "CognitoUserPool")
        super.init()
    }    
    
    /// Perform Login user in cognito
    ///
    /// - Note: Performs sign-in on cognito
    ///         Gets user additional attributes from cognito
    ///
    ///
    /// - Parameters:
    ///   - credentials: any class that conforms CognitoUserCredentialsProvider
    ///   - completion: returns LoginResponse as a decodable object.
    public func login<T>(with credentials: UserCredentials, completion: @escaping (ALResult<LoginResponse<T>>) -> Void) where T : Decodable {
        logger?.log(message: "Login user")
        credentialsStorage.lastLoginCredentials = credentials
        loginUser(with: credentials, completion: { [weak self] in self?.processLoginUserResult($0, completion: completion) })
    }
    
    private func processLoginUserResult<T>(_ result: ALResult<SessionResult>,
                                        completion: @escaping (ALResult<LoginResponse<T>>) -> Void) where T : Decodable  {
              result.map(encodeSessionResult)
                    .map({ try decoder.decode(LoginResponse<T>.self, from: $0) }) » completion
    }
    
    public func refreshSessionForCurrentUser(completion: @escaping (ALResult<String>) -> Void) {
        logger?.log(message: "Requested to refresh token")
        let user = pool.getUser()
        guard  let credentials = credentialsStorage.lastLoginCredentials  else {
            completion(.wrong(CognitoLoginError.UsernameNotFound))
            return
        }
        
        logger?.log(message: "Started  refresh token")
        let task = user.getSession(credentials.username,
                                   password: credentials.password,
                                   validationData: nil)
        task.continueWith(block: { (response) -> Any? in
            let result = ALResult(value: response.result?.idToken?.tokenString,
                                  error: response.error)
            
            result.do(work: { [weak self] _ in self?.logger?.log(message: "Received token ")})
                .onError({[weak self] in self?.logger?.log(error: $0) })
            completion(result)
            return task
        })
    }
    
    public func logout() {
        logger?.log(message: "Logging out...")
        let user = pool.getUser()
        user.signOut()
        credentialsStorage.lastLoginCredentials = nil
    }
    
    private func loginUser(with credentials: UserCredentials, completion: @escaping (ALResult<SessionResult>) -> Void) {
        let user = pool.getUser()
        userLogin(credentials.username,
                  password: credentials.password,
                  using: user,
                  completion: { (session) in
                       session.map({($0, user, [], credentials.username)})
                              .map(SessionResult.init)
                              .do(work:{ [weak self] in
                                    self?.getDetails(for: $0, completion: completion)
                              })
                              .onError({ completion(.wrong($0)) })
                  })
    }
    
    private func userLogin(_ id: String,
                           password: String,
                           using user: AWSCognitoIdentityUser,
                           completion: @escaping (ALResult<AWSCognitoIdentityUserSession>) -> Void) {
            logger?.log(message: "Getting session...")
            let task = user.getSession(id, password: password, validationData: nil)
            task.continueWith(block: { (response) -> Any? in
                let resp = ALResult(value: response.result,
                                    error: response.error)
                completion(resp)
                return task
            })
    }
    
    private func encodeSessionResult(_ sessionResult: SessionResult) throws -> Data {
        return try encoder.encode(sessionResult)
    }
    
    private func getDetails(for session: SessionResult, completion: @escaping (ALResult<SessionResult>) -> Void) {
            logger?.log(message: "Getting details...")
            let task = session.user.getDetails()
            task.continueWith { (response) -> Any? in
                let result = ALResult(value: response.result,
                                      error: response.error)
                result.map({ $0.userAttributes ?? [] })
                      .map(session.newAttributest)
                      .map({ $0.newUserName(new: response.result?.username ?? "") })
                    » completion
                return task
            }
    }
}


