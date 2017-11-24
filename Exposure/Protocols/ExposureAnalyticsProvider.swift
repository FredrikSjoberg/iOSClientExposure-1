//
//  ExposureAnalyticsProvider.swift
//  Exposure
//
//  Created by Fredrik Sjöberg on 2017-10-26.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import Player

public protocol ExposureAnalyticsProvider {
    init(environment: Environment, sessionToken: SessionToken)
    
    /// Exposure environment used for the active session.
    ///
    /// - Important: should match the `environment` used to authenticate the user.
    var environment: Environment { get }
    
    /// Token identifying the active session.
    ///
    /// - Important: should match the `environment` used to authenticate the user.
    var sessionToken: SessionToken { get }
    
    
    func onEntitlementRequested<Tech>(tech: Tech, request: AssetIdentifier) where Tech: PlaybackTech
    
    func onHandshakeStarted<Tech, Source>(tech: Tech, source: Source, request: AssetIdentifier) where Tech: PlaybackTech, Source: MediaSource
    
    /// Should prepare and configure the remaining parts of the Analytics environment.
    /// This step is required because we are dependant on the response from Exposure with regards to the playSessionId.
    ///
    /// Once this is called, a Dispatcher should be associated with the session.
    ///
    /// - parameter playSessionId: Unique identifier for the current playback session.
    /// - parameter asset: *EMP* asset identifiers.
    /// - parameter entitlement: The entitlement this session concerns
    /// - parameter heartbeatsProvider: Will deliver heartbeats metadata during the session
    func finalizePreparation(for playSessionId: String, asset: AssetIdentifier, with entitlement: PlaybackEntitlement, heartbeatsProvider: HeartbeatsProvider)
}

public protocol ExposureDownloadAnalyticsProvider {
    
    /// Exposure environment used for the active session.
    ///
    /// - Important: should match the `environment` used to authenticate the user.
    var environment: Environment { get }
    
    /// Token identifying the active session.
    ///
    /// - Important: should match the `environment` used to authenticate the user.
    var sessionToken: SessionToken { get }
    
    
    func onEntitlementRequested(tech: ExposureDownloadTask, assetId: String)
    
    func onHandshakeStarted(tech: ExposureDownloadTask, source: PlaybackEntitlement, assetId: String)
    
    func downloadStartedEvent(task: ExposureDownloadTask)
    func downloadPausedEvent(task: ExposureDownloadTask)
    func downloadResumedEvent(task: ExposureDownloadTask)
    func downloadCancelledEvent(task: ExposureDownloadTask)
    func downloadStoppedEvent(task: ExposureDownloadTask)
    func downloadCompletedEvent(task: ExposureDownloadTask)
    
    
    /// Triggered if the download process encounters an error during its lifetime
    ///
    /// - parameter ExposureDownloadTask: `ExposureDownloadTask` broadcasting the event
    /// - parameter error: `ExposureError` causing the event to fire
    func downloadErrorEvent(task: ExposureDownloadTask, error: ExposureError)
    
    /// Should prepare and configure the remaining parts of the Analytics environment.
    /// This step is required because we are dependant on the response from Exposure with regards to the playSessionId.
    ///
    /// Once this is called, a Dispatcher should be associated with the session.
    ///
    /// - parameter asset: *EMP* asset identifiers.
    /// - parameter entitlement: The entitlement this session concerns
    /// - parameter heartbeatsProvider: Will deliver heartbeats metadata during the session
    func finalizePreparation(assetId: String, with entitlement: PlaybackEntitlement, heartbeatsProvider: HeartbeatsProvider)
}
