//
//  Exposure.swift
//  Exposure
//
//  Created by Fredrik Sjöberg on 2017-03-20.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import Alamofire

public typealias JSON = [String: Any]

public protocol ExposureConvertible {
    init?(json: JSON)
}

public protocol JSONEncodable {
    func toJSON() -> JSON
}

public protocol Exposure {
    associatedtype Response
    associatedtype Parameters
    associatedtype Headers
    
    var endpointUrl: String { get }
    var parameters: Parameters { get }
    var headers: Headers { get }
}

public enum HTTPMethod {
    case post
    case put
    case get
    case delete
    
    internal var alamofireMethod: Alamofire.HTTPMethod {
        switch self {
        case .post: return .post
        case .put: return .put
        case .get: return .get
        case .delete: return .delete
        }
    }
}

let sessionManager: SessionManager = {
    let configuration = URLSessionConfiguration.default
    configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
    return SessionManager(configuration: configuration)
}()

// MARK: - REST API
extension Exposure where Parameters == JSON, Headers == HTTPHeaders? {
    
    public func request(_ method: HTTPMethod) -> ExposureRequest {
        let dataRequest = sessionManager
            .request(endpointUrl,
                     method: method.alamofireMethod,
                     parameters: parameters,
                     encoding: JSONEncoding.default,
                     headers: headers)
        return ExposureRequest(dataRequest: dataRequest)
    }
}

extension Exposure where Parameters == JSON?, Headers == HTTPHeaders? {
    public func request(_ method: HTTPMethod) -> ExposureRequest {
        if let params = parameters {
            let dataRequest = sessionManager
                .request(endpointUrl,
                         method: method.alamofireMethod,
                         parameters: params,
                         encoding: JSONEncoding.default,
                         headers: headers)
            return ExposureRequest(dataRequest: dataRequest)
        }
        else {
            let dataRequest = sessionManager
                .request(endpointUrl,
                         method: method.alamofireMethod,
                         headers: headers)
            return ExposureRequest(dataRequest: dataRequest)
        }
    }
}
