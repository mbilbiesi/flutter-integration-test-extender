//
//  TestServer.swift
//  aws_integration_test
//
//  Created by Mazen Bilbiesi on 31/03/2023.
//

import Foundation
import Telegraph
import Darwin

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
//            let port = generateRandomPort();
//            TestServerConfig.serverPort = port;
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
    
    /* Get a random available port */
    private func generateRandomPort() -> Int {
        let lowerPortNumber = 49152
        let upperPortNumber = 65535
        var portNumber = Int(arc4random_uniform(UInt32(upperPortNumber - lowerPortNumber))) + lowerPortNumber
        while !isPortAvailable(port: portNumber) {
            portNumber = Int(arc4random_uniform(UInt32(upperPortNumber - lowerPortNumber))) + lowerPortNumber
        }
        return portNumber
    }
    
    private func isPortAvailable(port: Int) -> Bool {
        var socketFileDescriptor: Int32 = -1
        var socketAddressIn = sockaddr_in()
        socketAddressIn.sin_len = UInt8(MemoryLayout.size(ofValue: socketAddressIn))
        socketAddressIn.sin_family = sa_family_t(AF_INET)
        socketAddressIn.sin_port = CFSwapInt16HostToBig(UInt16(port))
        socketAddressIn.sin_addr = in_addr(s_addr: inet_addr("127.0.0.1"))
        socketFileDescriptor = socket(AF_INET, SOCK_STREAM, 0)
        if socketFileDescriptor == -1 {
            return false
        }
        var bindAddress = socketAddressIn
        let bindAddressLength = socklen_t(MemoryLayout.size(ofValue: bindAddress))
        memcpy(&bindAddress, &socketAddressIn, Int(bindAddressLength))
        
        // Set up a timeout for the bind call
        let timeoutSeconds = 1
        let timeoutMicroseconds = 0
        var timeout = timeval(tv_sec: timeoutSeconds, tv_usec: __darwin_suseconds_t(timeoutMicroseconds))
        setsockopt(socketFileDescriptor, SOL_SOCKET, SO_RCVTIMEO, &timeout, socklen_t(MemoryLayout.size(ofValue: timeout)))
        setsockopt(socketFileDescriptor, SOL_SOCKET, SO_SNDTIMEO, &timeout, socklen_t(MemoryLayout.size(ofValue: timeout)))
        
        let bindReturn = withUnsafePointer(to: &bindAddress) {
            bind(socketFileDescriptor, UnsafePointer<sockaddr>(OpaquePointer($0)), bindAddressLength)
        }
        close(socketFileDescriptor)
        if bindReturn == -1 {
            return false
        }
        return true
    }
}
