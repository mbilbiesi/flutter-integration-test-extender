//
//  TestServer.swift
//  aws_integration_test
//
//  Created by Mazen Bilbiesi on 31/03/2023.
//

import Foundation
import Telegraph

@objc public class TestServer: NSObject {
    
    // Initiate the server URL & port to be global vars
    @objc public class TestServerConfig: NSObject {
        @objc public static let serverUrl = "127.0.0.1"
        @objc public static var serverPort = 62000
    }
    
    // This is an in-memory object to save the value of test results
    @objc public private(set) var storedResults: [String: String]? = nil
    var server: Server?
    
    @objc public func start() {
        server = Server()
        server?.route(.POST, "/results", storeResult)
        server?.route(.GET, "/results", retrieveResult)
        
        do {
            try server?.start(port: TestServerConfig.serverPort, interface: TestServerConfig.serverUrl)
            print("TestServer successfully started on: http://\(TestServerConfig.serverUrl):\(TestServerConfig.serverPort)")
        } catch {
            print("Failed to start TestServer: \(error)")
        }
    }
    
    @objc public func stop() {
        server?.stop()
    }
    
    private func storeResult(request: HTTPRequest) -> HTTPResponse {
        guard let arguments = try? JSONDecoder().decode([String: String].self, from: request.body) else {
            //handle the response if an error
            let responseError = ["error": "Invalid request body"]
            let jsonData = try! JSONEncoder().encode(responseError)
            return HTTPResponse(.badRequest, body: jsonData)
        }
        
        // store the value in the global results var
        self.storedResults = arguments
        
        // handle the response if success
        let responseDict = ["message": "Results stored successfully"]
        let jsonData = try! JSONEncoder().encode(responseDict)
        return HTTPResponse(.badRequest, body: jsonData)
    }
    
    private func retrieveResult(request: HTTPRequest) -> HTTPResponse {
        let responseData = try! JSONEncoder().encode(storedResults)
        return HTTPResponse(.ok, body: responseData)
    }
}
