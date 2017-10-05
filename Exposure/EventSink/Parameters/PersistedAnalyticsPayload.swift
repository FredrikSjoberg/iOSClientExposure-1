//
//  PersistedAnalyticsPayload.swift
//  Exposure
//
//  Created by Fredrik Sjöberg on 2017-10-02.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

/// Convenience struct used to realize persisted `AnalyticsPayload` represented as *JSON*.
/// This is basicly a wrapper around the *JSON* payload that conforms to `AnalyticsPayload` to enable quick integration.
internal struct PersistedAnalyticsPayload: AnalyticsPayload, Decodable {
    /// Internal *JSON* representation
    private let jsonRepresentation: [String: AnyJSONType]
    
    /// `AnalyticsPayload` conformance
    internal var jsonPayload: [String : Any] {
        return jsonRepresentation
    }
}