//Copyright © 2018 Ethan Abrams. All rights reserved.
import Foundation
import SwiftWebSocket
public class WebSocketRequestResponse: AsyncRequestResponse {
    
    private var responseListeners = Dictionary<UUID, (Message) -> ()>()
    private var listeners = [String : Dictionary<UUID, (Message) -> ()>]()
    private var socket: WebSocket
    private var timer: Timer?
    
    init(address: String, additionalHTTPHeaders: Dictionary<String, String>) {
        var request = URLRequest(url: URL(string: address)!)
        for key in additionalHTTPHeaders.keys {
            request.addValue(additionalHTTPHeaders[key]!, forHTTPHeaderField: key)
        }
        self.socket = WebSocket(request: request)
        socket.event.error = {error in
            print(type(of: error))
            print(error)
        }
        
        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(withTimeInterval: 500, repeats: true, block: {(timer) in
                self.socket.ping()
            })
        }
        
        
        socket.event.pong = {data in
            print("has been ponged: \(data)")
        }
        //RunLoop.
        socket.event.message = {msg in
            if (type(of: msg) == type(of: [UInt8]())) {
                let incomingData = Data(msg as! [UInt8])
                let rawJSON = try! JSONSerialization.jsonObject(with: incomingData, options: []) as! [String: Any]
                let message = Message(dict: rawJSON)
                
                if message == nil {
                    
                } else {
                    self.proccessIncomingMessage(message: message!)
                }
                
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
    
    private func proccessIncomingMessage(message: Message) {
        //print(message)
        if message.command == nil {
            let listener = self.responseListeners[UUID(uuidString: message.key!)!]!
            listener(message)
            self.responseListeners.removeValue(forKey: UUID(uuidString: message.key!)!)
        } else {
            if self.listeners[message.command!] != nil {
                for listener in (self.listeners[(message.command)!]?.values)! {
                    listener(message)
                }
            }
        }
    }
    
    private func reconnect() {
        socket.close()
        socket.send(Message(command: "RECONNECT", key: nil, data: nil, error: nil))
    }
    
    func sendMessage(command: String, payLoad: Any?, callback: ((Any?, ARRError?) -> ())?) {
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
        socket.send(messageToSend)
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




