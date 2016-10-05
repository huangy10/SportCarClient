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
    
    lazy var manager: Alamofire.SessionManager = {
        let m = Alamofire.SessionManager.default
        
        m.delegate.taskWillPerformHTTPRedirectionWithCompletion = {
            (session: URLSession, task: URLSessionTask, response: HTTPURLResponse,
            newRequest: URLRequest, completionHandler: (URLRequest?) -> ()) in
            var req: URLRequest = newRequest
            req.setValue(self.jwtToken, forHTTPHeaderField: "Authorization")
            completionHandler(req)
//            if let requestWithHeader: URLRequest = newRequest.mutableCopy() as? URLRequest {
//                requestWithHeader.setValue(self.jwtToken, forHTTPHeaderField: "Authorization")
//                completionHandler(requestWithHeader)
//            } else {
//                completionHandler(newRequest)
//            }
        }
        return m
    } ()
    
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
            url = url[0..<(url.characters.count - 1)]
        }
        return url
    }
    
    func responseChecker(
        _ requestURL: Alamofire.URLConvertible,
        _ response: Alamofire.DataResponse<Any>,
        dataField: String,
        onSuccess: SSSuccessCallback,
        onError: SSFailureCallback
        ) {
        switch response.result {
        case .failure(let err):
//            print(requestURL)
//            print(err)
            if let newError = self.internalErrorHandler(err as NSError) {
                onError("\(newError.code)")
            } else {
                onSuccess(nil)
            }
        case .success(let value):
            let json = JSON(value)
            if json["success"].boolValue {
                let result = json[dataField]
                onSuccess(result)
            } else {
                let code = json["code"].string ?? json["message"].string
                if code == "1402" {
                    NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: kAccontNolongerLogin), object: nil)
                }
                onError(code)
            }
        }
    }
    
    func internalErrorHandler(_ error: NSError) -> NSError? {
        return error
    }
    
    func post(
        _ URLString: URLConvertible,
        parameters: [String: Any]? = nil,
        withManager: Alamofire.SessionManager? = nil,
        encoding: ParameterEncoding = JSONEncoding.default,
        headers: [String: String]? = nil,
        responseQueue: DispatchQueue = DispatchQueue.main,
        responseDataField: String = "",
        onSuccess: SSSuccessCallback!,
        onProgress: SSProgressCallback? = nil,
        onError: SSFailureCallback!
    ) -> Alamofire.Request {
        var defaultHeader = self.defaultHeader
        if let userHeader = headers {
            defaultHeader.merge(dictionaries: userHeader)
        }
//        let req = (withManager ?? manager).request(.POST, URLString, parameters: parameters, encoding: encoding, headers: defaultHeader)
        var req = (withManager ?? manager).request(URLString, method: .post, parameters: parameters, encoding: encoding, headers: defaultHeader)
        
        req = req.responseJSON(queue: responseQueue) { (response) in
            self.responseChecker(URLString, response, dataField: responseDataField, onSuccess: onSuccess, onError: onError)
        }
        if let progressHandler = onProgress {
            req = req.downloadProgress(closure: { (p) in
                progressHandler(Float(p.fractionCompleted))
            })
        }
        return req
    }
    
    func get(
        _ URLString: URLConvertible,
        parameters: [String: Any]? = nil,
        encoding: ParameterEncoding = URLEncoding.default,
        headers: [String: String]? = nil,
        responseQueue: DispatchQueue = DispatchQueue.main,
        responseDataField: String = "",
        onSuccess: SSSuccessCallback!,
        onProgress: SSProgressCallback? = nil,
        onError: SSFailureCallback!
        ) -> Alamofire.Request {
        var defaultHeader = self.defaultHeader
        if let userHeader = headers {
            defaultHeader.merge(dictionaries: userHeader)
        }
//        let req = manager.request(.GET, URLString, parameters: parameters, encoding: encoding, headers: defaultHeader)
        var req = manager.request(URLString, method: .get, parameters: parameters, encoding: encoding, headers: defaultHeader)
        req = req.responseJSON(queue: responseQueue) { (response) in
            self.responseChecker(URLString, response, dataField: responseDataField, onSuccess: onSuccess, onError: onError)
        }
        if let progressHandler = onProgress {
//            req.progress { (_, written, total) in
//                let progress: Float = Float(written) / Float(total)
//                progressClosure(progress: progress)
//            }
            req.downloadProgress(closure: { (p) in
                progressHandler(Float(p.fractionCompleted))
            })
        }
        return req
    }
    
    func upload(
        _ URLString: URLConvertible,
        parameters: [String: Any]? = nil,
        encoding: ParameterEncoding = JSONEncoding.default,
        headers: [String: String]? = nil,
        responseQueue: DispatchQueue = DispatchQueue.main,
        responseDataField: String = "",
        onSuccess: SSSuccessCallback!,
        onProgress: SSProgressCallback? = nil,
        onError: SSFailureCallback!
        ) {
        var defaultHeader = self.defaultHeader
        if let userHeader = headers {
            defaultHeader.merge(dictionaries: userHeader)
        }
        guard let parameters = parameters else {
            assertionFailure()
            return
        }
//        manager.upload(.POST, URLString, headers: defaultHeader, multipartFormData: { (form) in
//            for (key, value) in parameters {
//                if let text = value as? String {
//                    form.appendBodyPart(data: text.data(using: String.Encoding.utf8, allowLossyConversion: false)!, name: key)
//                } else if let image = value as? UIImage {
//                    form.appendBodyPart(data: UIImagePNGRepresentation(image)!, name: key, fileName: "\(key).png", mimeType: "image/png")
//                } else if let fileURL = value as? URL {
//                    form.appendBodyPart(fileURL: fileURL, name: key, fileName: "key.m4a", mimeType: "audio/mp4")
//                } else if let number = value as? Int {
//                    form.appendBodyPart(data: "\(number)".data(using: String.Encoding.utf8, allowLossyConversion: false)!, name: key)
//                    
//                } else if let double = value as? Double {
//                    form.appendBodyPart(data: "\(double)".data(using: String.Encoding.utf8, allowLossyConversion: false)!, name: key)
//                } else {
//                    do {
//                        let data = try JSON(value).rawData()
//                        form.appendBodyPart(data: data, name: key)
//                    } catch {
//                        assertionFailure("Unsupported form data type")
//                    }
//                }
//            }
//            }) { (result) in
//                switch result {
//                case .success(let request, _, _):
//                    if let progressClosure = onProgress {
//                        request.progress({ (_, written, total) in
//                            let progress = Float(written) / Float(total)
//                            progressClosure(progress: progress)
//                        })
//                    }
//                    request.responseJSON(responseQueue, completionHandler: { (response) in
//                        self.responseChecker(URLString, response, dataField: responseDataField, onSuccess: onSuccess, onError: onError)
//                    })
//                case .failure(_):
//                    responseQueue.async(execute: {
//                        onError(code: "Form Data Encode Error")
//                    })
//                }
//        }
        
        manager.upload(multipartFormData: { (form) in
            for (key, value) in parameters {
                if let text = value as? String {
                    form.append(text.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: key)
                } else if let image = value as? UIImage {
                    form.append(UIImagePNGRepresentation(image)!, withName: key, fileName: "\(key).png", mimeType: "image/png")
                } else if let fileURL = value as? URL {
                    form.append(fileURL, withName: key, fileName: "key.m4a", mimeType: "audio/mp4")
                } else if let number = value as? Int {
                    form.append("\(number)".data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: key)
                } else if let double = value as? Double {
                    form.append("\(double)".data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: key)
                } else {
                    do {
                        let data = try JSON(value).rawData()
                        form.append(data, withName: key)
                    } catch {
                        assertionFailure("Unsupported form data type")
                    }
                }
            }
            }, to: URLString, method: .post, headers: defaultHeader) { (result) in
                switch result {
                case .success(let request, _, _):
                    if let progressClosure = onProgress {
//                        request.progress({ (_, written, total) in
//                            let progress = Float(written) / Float(total)
//                            progressClosure(progress: progress)
//                        })
                        request.uploadProgress(closure: { ( p) in
                            progressClosure(Float(p.fractionCompleted))
                        })
                    }
                    request.responseJSON(queue: responseQueue, options: .allowFragments, completionHandler: { (response) in
                        self.responseChecker(URLString, response, dataField: responseDataField, onSuccess: onSuccess, onError: onError)
                    })
//                    request.responseJSON(responseQueue, completionHandler: { (response) in
//                        self.responseChecker(URLString, response, dataField: responseDataField, onSuccess: onSuccess, onError: onError)
//                    })
                case .failure(_):
                    responseQueue.async(execute: {
                        onError("Form Data Encode Error")
                    })
                }
        }
    }
}
