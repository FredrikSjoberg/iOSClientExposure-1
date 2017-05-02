//
//  PlaybackEntitlement.swift
//  Exposure
//
//  Created by Fredrik Sjöberg on 2017-03-23.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct PlaybackEntitlement {
    public let playToken: String? // Play token to use for either PlayReady or MRR. Will be empty if the status is not SUCCESS.
    
    public let edrm: EDRMConfiguration? // The EDRM specific configuration. Will be empty if the status is not SUCCESS.
    public let fairplay: FairplayConfiguration? // The Fairplay specific configuration. Will be empty if the status is not SUCCESS or nor Fairplay configurations.
    public let mediaLocator: String? //The information needed to locate the media. FOR EDRM this will be the media uid, for other formats it's the URL of the media.
    public let licenseExpiration: String? // The datetime of expiration of the drm license.
    public let licenseExpirationReason: ExpirationReason? //The reason of expiration of the drm license.
    public let licenseActivation: String? // The datetime of activation of the drm license.,
    public let playTokenExpiration: String? // The expiration of the the play token. The player needs to be initialized and done the play call before this.
    public let entitlementType: EntitlementType? // The type of entitlement that granted access to this play.
    public let live: Bool? // If this is a live entitlement.
    public let playSessionId: String? // Unique id of this playback session, all analytics events for this session should be reported on with this id
    public let ffEnabled: Bool? // If fast forward is enabled
    public let timeshiftEnabled: Bool? // If timeshift is disabled
    public let rwEnabled: Bool? // If rewind is enabled
    public let minBitrate: Int? // Min bitrate to use
    public let maxBitrate: Int? // Max bitrate to use
    public let maxResHeight: Int? // Max height resolution
    public let airplayBlocked: Bool? // If airplay is blocked
    public let mdnRequestRouterUrl: String? // MDN Request Router Url
    
    public enum ExpirationReason {
        case success
        case notEntitled
        case geoBlocked
        case downloadBlocked
        case deviceBlocked
        case licenseExpired
        case notAvailableInFormat
        case concurrentStreamsLimitReached
        case notEnabled
        case gapInEPG
        case epgPlayMaxHours
        case other(reason: String)
        
        public init?(string: String?) {
            guard let value = string else { return nil }
            self = ExpirationReason(string: value)
        }
        
        public init(string: String) {
            switch string {
            case "SUCCESS": self = .success
            case "NOT_ENTITLED": self = .notEntitled
            case "GEO_BLOCKED": self = .geoBlocked
            case "DOWNLOAD_BLOCKED": self = .downloadBlocked
            case "DEVICE_BLOCKED": self = .deviceBlocked
            case "LICENSE_EXPIRED": self = .licenseExpired
            case "NOT_AVAILABLE_IN_FORMAT": self = .notAvailableInFormat
            case "CONCURRENT_STREAMS_LIMIT_REACHED": self = .concurrentStreamsLimitReached
            case "NOT_ENABLED": self = .notEnabled
            case "GAP_IN_EPG": self = .gapInEPG
            case "EPG_PLAY_MAX_HOURS": self = .epgPlayMaxHours
            default: self = .other(reason: string)
            }
        }
    }
    
    public enum EntitlementType {
        case tvod
        case svod
        case fvod
        case other(type: String)
        
        
        public init?(string: String?) {
            guard let value = string else { return nil }
            self = EntitlementType(string: value)
        }
        
        public init(string: String) {
            switch string {
            case "TVOD": self = .tvod
            case "SVOD": self = .svod
            case "FVOD": self = .fvod
            default: self = .other(type: string)
            }
        }
    }
}

extension PlaybackEntitlement: ExposureConvertible {
    public init?(json: Any) {
        let actualJSON = SwiftyJSON.JSON(json)
        
        playToken = actualJSON[JSONKeys.playToken.rawValue].string
        
        edrm = EDRMConfiguration(json: actualJSON[JSONKeys.edrm.rawValue].dictionaryObject ?? [:])
        fairplay = FairplayConfiguration(json: actualJSON[JSONKeys.fairplay.rawValue].dictionaryObject ?? [:])
        
        mediaLocator = actualJSON[JSONKeys.mediaLocator.rawValue].string
        licenseExpiration = actualJSON[JSONKeys.licenseExpiration.rawValue].string
        licenseExpirationReason = ExpirationReason(string: actualJSON[JSONKeys.licenseExpirationReason.rawValue].string)
        licenseActivation = actualJSON[JSONKeys.licenseActivation.rawValue].string
        
        playTokenExpiration = actualJSON[JSONKeys.playTokenExpiration.rawValue].string
        entitlementType = EntitlementType(string: actualJSON[JSONKeys.entitlementType.rawValue].string)
        
        live = actualJSON[JSONKeys.live.rawValue].bool
        playSessionId = actualJSON[JSONKeys.playSessionId.rawValue].string
        ffEnabled = actualJSON[JSONKeys.ffEnabled.rawValue].bool
        timeshiftEnabled = actualJSON[JSONKeys.timeshiftEnabled.rawValue].bool
        rwEnabled = actualJSON[JSONKeys.rwEnabled.rawValue].bool
        minBitrate = actualJSON[JSONKeys.minBitrate.rawValue].int
        maxBitrate = actualJSON[JSONKeys.maxBitrate.rawValue].int
        maxResHeight = actualJSON[JSONKeys.maxResHeight.rawValue].int
        airplayBlocked = actualJSON[JSONKeys.airplayBlocked.rawValue].bool
        mdnRequestRouterUrl = actualJSON[JSONKeys.mdnRequestRouterUrl.rawValue].string
    }
    
    internal enum JSONKeys: String {
        case playToken = "playToken"
        case edrm = "edrmConfig"
        case fairplay = "fairplayConfig"
        case mediaLocator = "mediaLocator"
        case licenseExpiration = "licenseExpiration"
        case licenseExpirationReason = "licenseExpirationReason"
        case licenseActivation = "licenseActivation"
        case playTokenExpiration = "playTokenExpiration"
        case entitlementType = "entitlementType"
        case live = "live"
        case playSessionId = "playSessionId"
        case ffEnabled = "ffEnabled"
        case timeshiftEnabled = "timeshiftEnabled"
        case rwEnabled = "rwEnabled"
        case minBitrate = "minBitrate"
        case maxBitrate = "maxBitrate"
        case maxResHeight = "maxResHeight"
        case airplayBlocked = "airplayBlocked"
        case mdnRequestRouterUrl = "mdnRequestRouterUrl"
    }
}