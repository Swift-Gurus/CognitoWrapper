//
//  CognitoWrapperAuthenticationErrorDecorator.swift
//  AWSAuthCore
//
//  Created by Kalpesh Thakare on 2019-09-03.
//

import Foundation
import EitherResult
import AWSCognitoIdentityProvider

enum AuthenticationError : LocalizedError
{
    case invalidEmployeeID

    var errorDescription: String? {
        switch self {
        case .invalidEmployeeID:
            return "Invalid Employee ID"
        }
    }
}


final public class CognitoWrapperAuthenticationErrorDecorator: CognitoAuth {

    let decorated : CognitoAuth

    public init(decorated: CognitoAuth) {
        self.decorated = decorated
    }

    public func login<T>(with credentials: UserCredentials, completion: @escaping (ALResult<LoginResponse<T>>) -> Void) where T : Decodable {

        let decoratedCompletion: (ALResult<LoginResponse<T>>) -> Void = { [weak self] (result) in

            guard let `self` = self else { return }

            result.onError({ (appSynNetworkError) in
                let error = self.processNetworkError(appSynNetworkError)
                completion(.wrong(error)) })
            .do(work: {completion(.right($0))})
        }
        decorated.login(with: credentials, completion: decoratedCompletion)
    }

    public func logout() {
        decorated.logout()
    }

    private func processNetworkError(_ error: Error) -> Error {
        guard let cognitoError = AWSCognitoIdentityProviderErrorType(rawValue: (error as NSError).code) else {
            return error
        }

        switch cognitoError {
        case .userNotFound:
            return AuthenticationError.invalidEmployeeID

        default:
            return error
        }
    }
}
