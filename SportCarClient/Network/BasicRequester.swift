//
//  BasicRequester.swift
//  SportCarClient
//
//  Created by 黄延 on 16/5/3.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class BasicRequester {
    
    private lazy var __once: () = {
            
            m.delegate.taskWillPerformHTTPRedirectionWithCompletion = {
                (session: URLSession, task: URLSessionTask, response: HTTPURLResponse,
                newRequest: URLRequest, completionHandler: (URLRequest?) -> Void) in
                
                if let requestWithHeader: NSMutableURLRequest = (newRequest as NSURLRequest).mutableCopy() as? NSMutableURLRequest {
                    requestWithHeader.setValue(BasicRequester.jwtToken, forHTTPHeaderField: "Authorization")
                    completionHandler(requestWithHeader)
                } else {
                    completionHandler(newRequest)
                }
            }
        }()
    
    var manager: Alamofire.Manager {
        let m = Alamofire.Manager.sharedInstance
        var onceToken: Int = 0
        _ = self.__once
        return m
    }
    
    fileprivate var jwtToken: String {
        if MainManager.sharedManager.hostUser == nil {
            return ""
        }
        return MainManager.sharedManager.jwtToken
    }
    
    fileprivate var defaultHeader: [String: String] {
        return ["Authorization": jwtToken]
    }
    
    var urlMap: [String: String] {
        assertionFailure()
        return [:]
    }
    
    var namespace: String {
        assertionFailure()
        return ""
    }
    
    func urlForName(_ name: String, param: [String: String]? = nil) -> String {
        guard var url = urlMap[name] else {
            assertionFailure("URL mapping not defined")
            return ""
        }
        if let param = param {
            for (key, value) in param {
                url = (url as NSString).replacingOccurrences(of: "<\(key)>", with: value)
            }
        }
        url = "\(kProtocalName)://\(kHostName):\(kPortName)/\(namespace)/\(url)"
        if url.hasSuffix("/") {
            // remove the trailing slash
            url = url[0..<url.length - 1]
        }
        return url
    }
    
    func responseChecker(
        _ requestURL: URLStringConvertible,
        _ response: Alamofire.Response<AnyObject, NSError>,
        dataField: String,
        onSuccess: SSSuccessCallback,
        onError: SSFailureCallback
        ) {
        switch response.result {
        case .failure(let err):
//            print(requestURL)
//            print(err)
            if let newError = self.internalErrorHandler(err) {
                onError(code: "\(newError.code)")
            } else {
                onSuccess(json: nil)
            }
        case .success(let value):
            let json = JSON(value)
            if json["success"].boolValue {
                let result = json[dataField]
                onSuccess(json: result)
            } else {
                let code = json["code"].string ?? json["message"].string
                if code == "1402" {
                    NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: kAccontNolongerLogin), object: nil)
                }
                onError(code: code)
            }
        }
    }
    
    func internalErrorHandler(_ error: NSError) -> NSError? {
        return error
    }
    
    func post(
        _ URLString: URLStringConvertible,
        parameters: [String: AnyObject]? = nil,
        withManager: Alamofire.Manager? = nil,
        encoding: ParameterEncoding = .url,
        headers: [String: String]? = nil,
        responseQueue: DispatchQueue = DispatchQueue.main,
        responseDataField: String = "",
        onSuccess: SSSuccessCallback!,
        onProgress: SSProgressCallback? = nil,
        onError: SSFailureCallback!
    ) -> Alamofire.Request {
        var defaultHeader = self.defaultHeader
        if let userHeader = headers {
            defaultHeader.merge(userHeader)
        }
        let req = (withManager ?? manager).request(.POST, URLString, parameters: parameters, encoding: encoding, headers: defaultHeader)
        if let progressClosure = onProgress {
            req.progress { (_, written, total) in
                let progress: Float = Float(written) / Float(total)
                progressClosure(progress: progress)
            }
        }
        req.responseJSON(responseQueue) { (response) in
            self.responseChecker(URLString, response, dataField: responseDataField, onSuccess: onSuccess, onError: onError)
        }
        return req
    }
    
    func get(
        _ URLString: URLStringConvertible,
        parameters: [String: AnyObject]? = nil,
        encoding: ParameterEncoding = .url,
        headers: [String: String]? = nil,
        responseQueue: DispatchQueue = DispatchQueue.main,
        responseDataField: String = "",
        onSuccess: SSSuccessCallback!,
        onProgress: SSProgressCallback? = nil,
        onError: SSFailureCallback!
        ) -> Alamofire.Request {
        var defaultHeader = self.defaultHeader
        if let userHeader = headers {
            defaultHeader.merge(userHeader)
        }
        let req = manager.request(.GET, URLString, parameters: parameters, encoding: encoding, headers: defaultHeader)
        req.responseJSON(responseQueue) { (response) in
            self.responseChecker(URLString, response, dataField: responseDataField, onSuccess: onSuccess, onError: onError)
        }
        if let progressClosure = onProgress {
            req.progress { (_, written, total) in
                let progress: Float = Float(written) / Float(total)
                progressClosure(progress: progress)
            }
        }
        return req
    }
    
    func upload(
        _ URLString: URLStringConvertible,
        parameters: [String: AnyObject]? = nil,
        encoding: ParameterEncoding = .url,
        headers: [String: String]? = nil,
        responseQueue: DispatchQueue = DispatchQueue.main,
        responseDataField: String = "",
        onSuccess: SSSuccessCallback!,
        onProgress: SSProgressCallback? = nil,
        onError: SSFailureCallback!
        ) {
        var defaultHeader = self.defaultHeader
        if let userHeader = headers {
            defaultHeader.merge(userHeader)
        }
        guard let parameters = parameters else {
            assertionFailure()
            return
        }
        
        manager.upload(.POST, URLString, headers: defaultHeader, multipartFormData: { (form) in
            for (key, value) in parameters {
                if let text = value as? String {
                    form.appendBodyPart(data: text.data(using: String.Encoding.utf8, allowLossyConversion: false)!, name: key)
                } else if let image = value as? UIImage {
                    form.appendBodyPart(data: UIImagePNGRepresentation(image)!, name: key, fileName: "\(key).png", mimeType: "image/png")
                } else if let fileURL = value as? URL {
                    form.appendBodyPart(fileURL: fileURL, name: key, fileName: "key.m4a", mimeType: "audio/mp4")
                } else if let number = value as? Int {
                    form.appendBodyPart(data: "\(number)".data(using: String.Encoding.utf8, allowLossyConversion: false)!, name: key)
                    
                } else if let double = value as? Double {
                    form.appendBodyPart(data: "\(double)".data(using: String.Encoding.utf8, allowLossyConversion: false)!, name: key)
                } else {
                    do {
                        let data = try JSON(value).rawData()
                        form.appendBodyPart(data: data, name: key)
                    } catch {
                        assertionFailure("Unsupported form data type")
                    }
                }
            }
            }) { (result) in
                switch result {
                case .success(let request, _, _):
                    if let progressClosure = onProgress {
                        request.progress({ (_, written, total) in
                            let progress = Float(written) / Float(total)
                            progressClosure(progress: progress)
                        })
                    }
                    request.responseJSON(responseQueue, completionHandler: { (response) in
                        self.responseChecker(URLString, response, dataField: responseDataField, onSuccess: onSuccess, onError: onError)
                    })
                case .failure(_):
                    responseQueue.async(execute: {
                        onError(code: "Form Data Encode Error")
                    })
                }
        }
    }
}
