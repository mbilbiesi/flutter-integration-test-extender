//
//  TestServerClient.swift
//  aws_integration_test
//
//  Created by Mazen Bilbiesi on 01/04/2023.
//

import Foundation
import Alamofire

@objc public class TestServerClient: NSObject {
    @objc public func sendPostRequestWithAlamofire(payload: [String: Any]) {
        let url = "http://localhost:8081/results"
        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        
        AF.request(url, method: .post, parameters: payload, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
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
