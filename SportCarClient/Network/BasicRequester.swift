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
    
    var manager: Alamofire.Manager {
        let m = Alamofire.Manager.sharedInstance
        var onceToken: dispatch_once_t = 0
        dispatch_once(&onceToken) {
            
            m.delegate.taskWillPerformHTTPRedirectionWithCompletion = {
                (session: NSURLSession, task: NSURLSessionTask, response: NSHTTPURLResponse,
                newRequest: NSURLRequest, completionHandler: NSURLRequest? -> Void) in
                
                if let requestWithHeader: NSMutableURLRequest = newRequest.mutableCopy() as? NSMutableURLRequest {
                    requestWithHeader.setValue(self.jwtToken, forHTTPHeaderField: "Authorization")
                    completionHandler(requestWithHeader)
                } else {
                    completionHandler(newRequest)
                }
            }
        }
        return m
    }
    
    private var jwtToken: String {
        if MainManager.sharedManager.hostUser == nil {
            return ""
        }
        return MainManager.sharedManager.jwtToken
    }
    
    private var defaultHeader: [String: String] {
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
    
    func urlForName(name: String, param: [String: String]? = nil) -> String {
        guard var url = urlMap[name] else {
            assertionFailure("URL mapping not defined")
            return ""
        }
        if let param = param {
            for (key, value) in param {
                url = (url as NSString).stringByReplacingOccurrencesOfString("<\(key)>", withString: value)
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
        requestURL: URLStringConvertible,
        _ response: Alamofire.Response<AnyObject, NSError>,
        dataField: String,
        onSuccess: SSSuccessCallback,
        onError: SSFailureCallback
        ) {
        switch response.result {
        case .Failure(let err):
            print(requestURL)
            print(err)
            if let newError = self.internalErrorHandler(err) {
                onError(code: "\(newError.code)")
            } else {
                onSuccess(json: nil)
            }
        case .Success(let value):
            let json = JSON(value)
            if json["success"].boolValue {
                let result = json[dataField]
                onSuccess(json: result)
            } else {
                let code = json["code"].string ?? json["message"].string
                if code == "1402" {
                    NSNotificationCenter.defaultCenter().postNotificationName(kAccontNolongerLogin, object: nil)
                }
                onError(code: code)
            }
        }
    }
    
    func internalErrorHandler(error: NSError) -> NSError? {
        return error
    }
    
    func post(
        URLString: URLStringConvertible,
        parameters: [String: AnyObject]? = nil,
        withManager: Alamofire.Manager? = nil,
        encoding: ParameterEncoding = .URL,
        headers: [String: String]? = nil,
        responseQueue: dispatch_queue_t = dispatch_get_main_queue(),
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
        URLString: URLStringConvertible,
        parameters: [String: AnyObject]? = nil,
        encoding: ParameterEncoding = .URL,
        headers: [String: String]? = nil,
        responseQueue: dispatch_queue_t = dispatch_get_main_queue(),
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
            print(response.request?.URL)
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
        URLString: URLStringConvertible,
        parameters: [String: AnyObject]? = nil,
        encoding: ParameterEncoding = .URL,
        headers: [String: String]? = nil,
        responseQueue: dispatch_queue_t = dispatch_get_main_queue(),
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
                    form.appendBodyPart(data: text.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: key)
                } else if let image = value as? UIImage {
                    form.appendBodyPart(data: UIImagePNGRepresentation(image)!, name: key, fileName: "\(key).png", mimeType: "image/png")
                } else if let fileURL = value as? NSURL {
                    form.appendBodyPart(fileURL: fileURL, name: key, fileName: "key.m4a", mimeType: "audio/mp4")
                } else if let number = value as? Int {
                    form.appendBodyPart(data: "\(number)".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: key)
                    
                } else if let double = value as? Double {
                    form.appendBodyPart(data: "\(double)".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name: key)
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
                case .Success(let request, _, _):
                    if let progressClosure = onProgress {
                        request.progress({ (_, written, total) in
                            let progress = Float(written) / Float(total)
                            progressClosure(progress: progress)
                        })
                    }
                    request.responseJSON(responseQueue, completionHandler: { (response) in
                        self.responseChecker(URLString, response, dataField: responseDataField, onSuccess: onSuccess, onError: onError)
                    })
                case .Failure(_):
                    dispatch_async(responseQueue, {
                        onError(code: "Form Data Encode Error")
                    })
                }
        }
    }
}
