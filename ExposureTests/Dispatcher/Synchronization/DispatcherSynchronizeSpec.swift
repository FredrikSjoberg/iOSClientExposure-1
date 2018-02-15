//
//  DispatcherSynchronizeSpec.swift
//  AnalyticsTests
//
//  Created by Fredrik Sjöberg on 2017-12-20.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

import Quick
import Nimble
@testable import Exposure

class DispatcherSynchronizeSpec: QuickSpec {
    let environment = Environment(baseUrl: "url", customer: "DispatcherCustomer", businessUnit: "DispatcherBusinessUnit")
    let sessionToken = SessionToken(value: "crmToken|DispatcherAccountId1|userId|anotherField|1000|2000|false|field|finalField")
    
    var heartbeatsProvider = MockedHeartbeatProvider()
    override func spec() {
        describe("Termination") {
            
            //
            // Synchronize with backend
            //      * onError
            //          - should trigger callback
            //      * onSuccess
            //          - should update configuration.synchronizedClockOffset
            //          - should update configuration.reportingTimeinterval
            //
            let event = Started(timestamp: 1000)
            
            it("Should forward errors during sync phase") {
                let dispatcher = Dispatcher(environment: self.environment,
                                            sessionToken: self.sessionToken,
                                            playSessionId: UUID().uuidString,
                                            startupEvents: [],
                                            heartbeatsProvider: self.heartbeatsProvider)
                let networkHandler = SynchronizeNetworkHandler()
                networkHandler.failsToSync = true
                dispatcher.networkHandler = networkHandler
                var syncError: ExposureError? = nil
                dispatcher.synchronize{ error in
                    syncError = error
                }
                expect(syncError).toEventuallyNot(beNil())
            }
            
            it("Should set the correct configuration on response") {
                let dispatcher = Dispatcher(environment: self.environment,
                                            sessionToken: self.sessionToken,
                                            playSessionId: UUID().uuidString,
                                            startupEvents: [],
                                            heartbeatsProvider: self.heartbeatsProvider)
                let networkHandler = SynchronizeNetworkHandler()
                dispatcher.networkHandler = networkHandler
                dispatcher.enqueue(event: event)
                
                expect(networkHandler.receivedClockDelta).toEventuallyNot(beNil())
               expect(networkHandler.receivedClockDelta).toEventually(beLessThan(SynchronizeNetworkHandler.acceptedDelta), timeout: 6)
            }
        }
    }
}