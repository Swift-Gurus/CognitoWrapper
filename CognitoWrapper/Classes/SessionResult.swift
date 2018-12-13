//
//  SessionResult.swift
//  AWSAuthCore
//
//  Created by Esteban Garro on 2018-12-11.
//

import Foundation
import AWSCognito
import AWSUserPoolsSignIn

/// Private struct that represents response from Cognito.
/// Shouldn't be revealed to the client
struct SessionResult: Encodable {
    let session: AWSCognitoIdentityUserSession
    let user: AWSCognitoIdentityUser
    let attributes: [AWSCognitoIdentityProviderAttributeType]
    let userName: String
    
    enum CodingKeys: String, CodingKey {
        case userName
        case authToken
        case data
    }
    
    init(session: AWSCognitoIdentityUserSession,
         user: AWSCognitoIdentityUser,
         attributes: [AWSCognitoIdentityProviderAttributeType] = [],
         userName: String) {
        self.session = session
        self.user = user
        self.attributes = attributes
        self.userName = userName
    }
    
    func newAttributest(attributes: [AWSCognitoIdentityProviderAttributeType]) -> SessionResult {
        return SessionResult(session: session, user: user, attributes: attributes,userName: userName)
    }
    
    func newUserName(new: String) -> SessionResult {
        return SessionResult(session: session, user: user, attributes: attributes, userName: new)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
    
        var dict = attributesAsDictionary
        dict[CodingKeys.userName.rawValue] = userName

        try container.encode(dict, forKey: .data)
        try container.encode(session.accessToken?.tokenString ?? "", forKey: .authToken)
    }

    private var attributesAsDictionary: [String: String] {
        return attributes.reduce([:], { (part, element) -> [String: String] in
            if let key = element.name?.replacingOccurrences(of: "custom:", with: ""),
                let val = element.value {
                var mPart = part
                mPart[key] = val
                return mPart
            } else {
                return part
            }
        })        
    }
}



