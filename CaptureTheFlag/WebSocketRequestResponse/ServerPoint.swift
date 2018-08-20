//Copyright © 2018 Ethan Abrams. All rights reserved.
import Foundation
import SwiftWebSocket
public class WebSocketRequestResponse: AsyncRequestResponse {
    
    private var responseListeners = Dictionary<UUID, (Message) -> ()>()
    private var listeners = [String : Dictionary<UUID, (Message) -> ()>]()
    private var socket: WebSocket?
    private var pingTimer: Timer? = nil
    private var pongTimer: Timer? = nil
    private var reconnectKey: String? = nil
    public var onReconnect: (() -> ())?
    private var serverUrl: String?
    
    
    init() {
        
        self.socket = WebSocket()
        
        socket?.event.error = {error in
            print(type(of: error))
            print(error)
        }
        
        socket?.event.close = { (int, string, bool) in
            print("websocket closed")
        }
        
        socket?.event.pong = {data in
            self.stopPongTimer()
            print("has been ponged: \(data)")
        }
        //RunLoop.
        socket?.event.message = {msg in
            if (type(of: msg) == type(of: [UInt8]())) {
                let incomingData = Data(msg as! [UInt8])
                let rawJSON = try! JSONSerialization.jsonObject(with: incomingData, options: []) as! [String: Any]
                let message = Message(dict: rawJSON)
                if message == nil {
                    print("invalid incoming message")
                } else {
                    self.proccessIncomingMessage(message: message!)
                }
                return
            }
            let msgAsString = msg as! String
            if msgAsString == "connected" {
                self.onReconnect?()
                return
            }
            let msgData = try! JSONSerialization.jsonObject(with: msgAsString.data(using: .utf8)!, options: []) as? [String:String]
            if let reconnectId = msgData?["RECONNECTID"] {
                self.reconnectKey = reconnectId
            } else {
                let msgDataString = msg as! String
                let msgData = try! JSONSerialization.jsonObject(with: msgDataString.data(using: .utf8)!, options: []) as! [String : Any]
                let message = Message(dict: msgData)
                if message == nil {
                    
                } else {
                    self.proccessIncomingMessage(message: message!)
                }
            }
        }
    }
    
    private func startReconnectTimers() {
        pingTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: {(timer) in
            //self.socket = nil
            self.socket?.ping()
            self.startPongTimer(seconds: 3)
        })
    }
    
    func open(address: String, additionalHTTPHeaders: Dictionary<String, String>) {
        print("URL: \(address)")
        self.serverUrl = address
        print()
        var request = URLRequest(url: URL(string: address)!)
        for key in additionalHTTPHeaders.keys {
            request.addValue(additionalHTTPHeaders[key]!, forHTTPHeaderField: key)
        }
        self.socket?.open(request: request)
        print("grgreerg")
    }
    
    func open(address: String) {
        self.serverUrl = address
        var request = URLRequest(url: URL(string: address)!)
        self.socket?.open(request: request)
        //self.startReconnectTimers()
    }
    
    
    private func proccessIncomingMessage(message: Message) {
        //print(message)
        if message.command == nil {
            print(message)
            let listener = self.responseListeners[UUID(uuidString: message.key!)!]!
            listener(message)
            self.responseListeners.removeValue(forKey: UUID(uuidString: message.key!)!)
        } else {
            print(message)
            if self.listeners[message.command!] != nil {
                for listener in (self.listeners[(message.command)!]?.values)! {
                    listener(message)
                }
            }
        }
    }
    
    func startPongTimer(seconds: Double) {
        print("starting the pong timer")
        self.pongTimer = Timer.scheduledTimer(withTimeInterval: seconds, repeats: false, block: {(timer) in
            self.initiateReconnect()
        })
    }
    
    
    
    private func stopPongTimer() {
        print("stopping the pong timer")
        self.pongTimer?.invalidate()
        self.pongTimer = nil
    }
    
    private func initiateReconnect() {
        print("initiating reconnect")
        //self.pingTimer?.invalidate()
        //self.pingTimer = nil
        print("closing the socket")
        self.socket?.close()
        var request = URLRequest(url: URL(string: self.serverUrl!)!)
        request.addValue(self.reconnectKey!, forHTTPHeaderField: "reconnect")
        self.socket?.open(request: request)
    }
    
    func close() {
        self.socket?.close()
    }
    
    func sendMessage(command: String, payLoad: Any?, callback: ((Any?, ARRError?) -> ())?) {
        print("send message is being called: \(command)")
        let key = UUID()
        let message = Message(command: command, key: key.uuidString, data: payLoad, error: nil)
        if callback != nil {
            func callackWrapper(msg: Message) {
                callback!(msg.data, msg.error)
            }
            self.responseListeners[key] = callackWrapper(msg:)
        }
        let messageAsDictionary = message.asDictionary()
        let messageToSend = try! JSONSerialization.data(withJSONObject: messageAsDictionary, options: [])
        //self.socket?.send(messageToSend)
        self.socket!.send(messageToSend)
    }
    
    func addListener(for command: String, callback: @escaping(Any?) -> ()) -> ListenerKey {
        var key = UUID()
        func callbackWrapper(msg: Message) {
            callback(msg.data)
        }
        if self.listeners[command] == nil {
            self.listeners[command] = Dictionary<UUID, (Message) -> ()>()
        }
        self.listeners[command]![key] = callbackWrapper(msg:)
        return ListenerKey(command: command, key: key)
    }
    
    func removeListener(listenerKey: ListenerKey) {
        listeners[listenerKey.command]!.removeValue(forKey: listenerKey.key)
    }
}

extension Message {
    init?(dict: Dictionary<String, Any>) {
        let keys = dict.keys
        
        if !keys.contains("command") || !keys.contains("key") ||
            !keys.contains("data") || !keys.contains("error") {
            return nil
        }
        self.command = dict["command"] as? String
        self.key = dict["key"] as? String
        if dict["data"] is NSNull {
            self.data = nil
        } else {
            self.data = dict["data"]
        }
        let pointErrorDict = dict["error"] as? [String:Any]
        if pointErrorDict == nil {
            self.error = nil
        } else {
            self.error = ARRError(dict: pointErrorDict!)
        }
        
    }
    
    func asDictionary() -> Dictionary<String, Any> {
        return [
            "command" : self.command,
            "key" : self.key,
            "data" : self.data,
            "error" : self.error
        ]
    }
}

extension ARRError {
    init?(dict: [String:Any]) {
        self.code = dict["code"] as! Int
        self.description = dict["description"] as! String
    }
}




