//
//  TestServerClient.swift
//  aws_integration_test
//
//  Created by Mazen Bilbiesi on 01/04/2023.
//

import Foundation
import Alamofire

@objc public class TestServerClient: NSObject {
    
    private let baseURL: URL
    
    @objc public init(baseURL: URL) {
        self.baseURL = baseURL
    }
    
    @objc public func sendPostRequestToStoreTestResult(path: String, payload: [String: Any]) {
        let url = baseURL.appendingPathComponent(path)
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        
        AF.request(url, method: .post, parameters: payload, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .responseDecodable(of: String.self) { response in
                switch response.result {
                case .success(let value):
                    print("Request successful")
                    print("Response: \(value)")
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
    }
    
}
