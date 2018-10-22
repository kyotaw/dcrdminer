//
//  Socket.swift
//  dcrdminer
//
//  Created by 渡部郷太 on 2018/10/21.
//  Copyright © 2018 watanabe kyota. All rights reserved.
//

import Foundation

public protocol SocketDelegate {
    func onData(data: NSData)
}

open class TcpIpSocket {
    init(host: String, port: Int) {
        self.host = host
        self.port = port
        self.socketInfo = SocketInfo(this: self)
        var socketContext = CFSocketContext(version: 0, info: &self.socketInfo, retain: nil, release: nil, copyDescription: nil)
        self.socket = CFSocketCreate(kCFAllocatorDefault, PF_INET6, SOCK_DGRAM, IPPROTO_UDP, CFSocketCallBackType.dataCallBack.rawValue, callout, &socketContext)

    }
    
    open func send(data: NSData) {
        sendData(socket: self.socket, data: data as CFData, host: self.host, port: self.port)
    }
    
    open var delegate: SocketDelegate?
    private let host: String
    private let port: Int
    private var socketInfo: SocketInfo! = nil
    private var socket: CFSocket! = nil
}

private class SocketInfo {
    init(this: TcpIpSocket) {
        self.this = this
    }
    let this: TcpIpSocket
}

private func callout(sock: CFSocket?, callbackType: CFSocketCallBackType, address: CFData?,
             data: UnsafeRawPointer?, info: UnsafeMutableRawPointer?) -> Void
{
    switch callbackType {
    case CFSocketCallBackType.dataCallBack:
        let socketInfo = info!.assumingMemoryBound(to: SocketInfo.self).pointee
        let data = Unmanaged<CFData>.fromOpaque(data!).takeUnretainedValue()
        socketInfo.this.delegate?.onData(data: data)
    default:
        break
    }
}

private func getIfAddress(ifName: String) -> String? {
    var ifaddrMemory : UnsafeMutablePointer<ifaddrs>?
    guard getifaddrs(&ifaddrMemory) == 0 else {
        return nil
    }
    defer {
        freeifaddrs(ifaddrMemory)
    }
    
    let ifap: UnsafeMutablePointer<ifaddrs>? = (ifaddrMemory
        .map {
            Array(sequence(first: $0) { $0.pointee.ifa_next })
        
        } ?? [])
        .filter {
            let addrFamily = $0.pointee.ifa_addr.pointee.sa_family
            return addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6)
            }.filter {
                return String(cString: $0.pointee.ifa_name) == ifName
            }.first
    
    guard let ifa = ifap else {
        return nil
    }
    
    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
    guard getnameinfo(ifa.pointee.ifa_addr,
                      socklen_t(ifa.pointee.ifa_addr.pointee.sa_len),
                      &hostname,
                      socklen_t(hostname.count),
                      nil,
                      socklen_t(0),
                      NI_NUMERICHOST) == 0 else
    {
        return nil
    }
    
    return String(cString: hostname)
}

func bindSocket(socket :CFSocket, port: Int) {
    guard let addr = getIfAddress(ifName: "en0") else {
        print("Get address failed")
        return
    }

    var sin = sockaddr_in()
    sin.sin_len = __uint8_t(MemoryLayout<sockaddr_in>.size)
    sin.sin_family = sa_family_t(AF_INET)
    sin.sin_port = in_port_t(UInt16(port).bigEndian)
    
    // String を CString として構造体に設定
    guard addr.withCString({ inet_pton(AF_INET, $0, &sin.sin_addr) }) == 1 else {
        print("Set IPv4 address failed")
        return
    }
    
    CFSocketSetAddress(socket, NSData(bytes: &sin, length: MemoryLayout<sockaddr_in>.size) as CFData)
}

func sendData(socket: CFSocket, data: CFData, host: String, port: Int) {
    var sin = sockaddr_in()
    sin.sin_len = __uint8_t(MemoryLayout<sockaddr_in>.size)
    sin.sin_family = sa_family_t(AF_INET)
    sin.sin_port = in_port_t(UInt16(port).bigEndian)
    
    guard host.withCString({ inet_pton(AF_INET, $0, &sin.sin_addr) }) == 1 else {
        print("Set IPv4 address failed")
        return
    }
    
    CFSocketSendData(socket, NSData(bytes: &sin, length: MemoryLayout<sockaddr_in>.size) as CFData, data, 1)
}
