//
//  FetchEpgProgram.swift
//  Exposure
//
//  Created by Fredrik Sjöberg on 2017-06-14.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

public struct FetchEpgProgram: Exposure, FilteredPublish {
    public typealias Response = Program
    
    public var endpointUrl: String {
        return environment.apiUrl + "/epg/" + channelId + "/program/" + programId + (airing ? "/airing" : "")
    }
    
    public var parameters: [String: Any] {
        return queryParams
    }
    
    public var headers: [String: String]? {
        return nil
    }
    
    
    public var publishFilter: PublishFilter
    
    internal var internalQuery: Query
    
    public let environment: Environment
    public let channelId: String
    public let programId: String
    
    internal init(environment: Environment, channelId: String, programId: String) {
        self.environment = environment
        self.channelId = channelId
        self.programId = programId
        self.publishFilter = PublishFilter()
        self.internalQuery = Query()
    }
    
    internal enum Keys: String {
        case onlyPublished = "onlyPublished"
    }
    
    internal var queryParams: [String: Any] {
        var params:[String: Any] = [
            Keys.onlyPublished.rawValue: publishFilter.onlyPublished
        ]
        
        return params
    }
}

// MARK: - Internal Query
extension FetchEpgProgram {
    public var airing: Bool {
        return internalQuery.airing
    }
    
    public func filter(airingOnly: Bool) -> FetchEpgProgram {
        var old = self
        old.internalQuery = Query(airing: airingOnly)
        return old
    }
    
    internal struct Query {
        internal let airing: Bool
        
        internal init(airing: Bool = false) {
            self.airing = airing
        }
    }
}

// MARK: - Request
extension FetchEpgProgram {
    public func request() -> ExposureRequest {
        return request(.get, encoding: ExposureURLEncoding.default)
    }
}