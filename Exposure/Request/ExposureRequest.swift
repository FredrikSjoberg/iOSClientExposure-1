//
//  ExposureRequest.swift
//  Exposure
//
//  Created by Fredrik Sjöberg on 2017-03-27.
//  Copyright © 2017 emp. All rights reserved.
//

import Foundation

/// Responsible for sending a request and receiving response from the server.
///
/// Errors are mapped to typed *ExposureErrors* by default. Specialized error handling can be performed through the `mapError(callback:)` function.
public class ExposureRequest<Object: Decodable> {
    /// Internal dataRequest handling the actual networking
    internal let dataRequest: Request
    
    internal init(dataRequest: Request) {
        self.dataRequest = dataRequest
    }
}


extension ExposureRequest {
    /// Response materialization.
    ///
    /// Once the request has been created, calling this method will trigger the request and materialize the response.
    ///
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: The code to be executed once the request has finished.
    /// - returns: `Self`
    @discardableResult
    public func response(queue: DispatchQueue? = nil, completionHandler: @escaping (ExposureResponse<Object>) -> Void) -> Self {
        dataRequest.response(responseSerializer: { request, response, data, error in
            guard error == nil, let jsonData = data else {
                if let networkingError = error as? Request.Networking {
                    if case Request.Networking.unacceptableStatusCode(code: let code) = networkingError, let statusData = data, let message = try? JSONDecoder().exposureDecode(ExposureResponseMessage.self, from: statusData) {
                        return .failure(error: ExposureError.exposureResponse(reason: message))
                    }
                    else {
                        return .failure(error: ExposureError.generalError(error: networkingError))
                    }
                }
                else {
                    return .failure(error: ExposureError.generalError(error: error!))
                }
            }
            
            do {
                let object = try JSONDecoder().exposureDecode(Object.self, from: jsonData)
                return .success(value: object)
            }
            catch let e {
                return .failure(error: e)
            }
        }) { (dataResponse: Response<Object>) in
            completionHandler(ExposureResponse(dataResponse: dataResponse))
        }
        return self
    }
    
    /// Response materialization.
    ///
    /// Once the request has been created, calling this method will trigger the request but only forward errors encountered.
    ///
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: The code to be executed once the request has finished.
    /// - returns: `Self`
    @discardableResult
    public func emptyResponse(queue: DispatchQueue? = nil, completionHandler: @escaping (ExposureError?) -> Void) -> Self {
        dataRequest.rawResponse(queue: queue) { request, response, data, error in
            guard error == nil else {
                if let networkingError = error as? Request.Networking {
                    if case Request.Networking.unacceptableStatusCode(code: let code) = networkingError, let statusData = data, let message = try? JSONDecoder().exposureDecode(ExposureResponseMessage.self, from: statusData) {
                        return completionHandler(ExposureError.exposureResponse(reason: message))
                    }
                    else {
                        return completionHandler(ExposureError.generalError(error: networkingError))
                    }
                }
                else {
                    return completionHandler(ExposureError.generalError(error: error!))
                }
            }
            completionHandler(nil)
        }
        return self
    }
    
    /// Response materialization.
    ///
    /// Once the request has been created, calling this method will trigger the request and return the retrieved data
    ///
    /// - parameter queue: The queue on which the completion handler is dispatched.
    /// - parameter completionHandler: The code to be executed once the request has finished.
    /// - returns: `Self`
    @discardableResult
    public func responseData(queue: DispatchQueue? = nil, completionHandler: @escaping (Data?, ExposureError?) -> Void) -> Self {
        dataRequest.rawResponse(queue: queue) { request, response, data, error in
            guard error == nil else {
                if let networkingError = error as? Request.Networking {
                    if case Request.Networking.unacceptableStatusCode(code: let code) = networkingError, let statusData = data, let message = try? JSONDecoder().exposureDecode(ExposureResponseMessage.self, from: statusData) {
                        return completionHandler(nil, ExposureError.exposureResponse(reason: message))
                    }
                    else {
                        return completionHandler(nil, ExposureError.generalError(error: networkingError))
                    }
                }
                else {
                    return completionHandler(nil, ExposureError.generalError(error: error!))
                }
            }
            completionHandler(data, nil)
        }
        return self
    }
}

extension JSONDecoder {
    internal func exposureDecode<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable {
        do {
            return try self.decode(type, from: data)
        }
        catch let decodingError as DecodingError {
            switch decodingError {
            case .dataCorrupted(let context): throw ExposureError.serialization(reason: .objectSerialization(reason: context.debugDescription, json: data))
            case .keyNotFound(_, let context): throw ExposureError.serialization(reason: .objectSerialization(reason: context.debugDescription, json: data))
            case .typeMismatch(_, let context): throw ExposureError.serialization(reason: .objectSerialization(reason: context.debugDescription, json: data))
            case .valueNotFound(_, let context): throw ExposureError.serialization(reason: .objectSerialization(reason: context.debugDescription, json: data))
            }
        }
        catch (let e) {
            throw ExposureError.serialization(reason: .objectSerialization(reason: "Unable to serialize object: \(e.localizedDescription)", json: data))
        }
    }
}

extension ExposureRequest {
    // MARK: State
    
    /// Resumes the request.
    open func resume() {
        dataRequest.resume()
    }
    
    /// Suspends the request.
    open func suspend() {
        dataRequest.suspend()
    }
    
    /// Cancels the request.
    open func cancel() {
        dataRequest.cancel()
    }
}

extension ExposureRequest {
    /// Validates that the response has a status code in the specified sequence.
    ///
    /// If validation fails, subsequent calls to response handlers will have an associated error.
    ///
    /// - parameter range: The range of acceptable status codes.
    /// - returns: The request.
    public func validate<S : Sequence>(statusCode acceptableStatusCodes: S) -> Self where S.Iterator.Element == Int {
        dataRequest.validate(statusCode: acceptableStatusCodes)
        return self
    }
    
    /// Validates that the response has a status code in the default acceptable range of 200...299, and that the content
    /// type matches any specified in the Accept HTTP header field.
    ///
    /// If validation fails, subsequent calls to response handlers will have an associated error.
    ///
    /// - returns: The request.
    public func validate() -> Self {
        dataRequest.validate()
        return self
    }
}

