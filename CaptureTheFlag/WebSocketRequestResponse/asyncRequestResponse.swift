//
//  asyncRequestResponse.swift
//  CaptureTheFlag
//
//  Created by Ethan Abrams on 7/31/18.
//  Copyright © 2018 Joe Durand. All rights reserved.
//

import Foundation
struct ARRError {
    var code: Int
    var description: String
}

protocol AsyncRequestResponse: class {
    var onReconnect: (() -> ())? {set get}
    func sendMessage(command: String, payLoad: Any?, callback: ((Any?, ARRError?) -> ())?)
    func addListener(for: String, callback: @escaping (Any?) -> ()) -> ListenerKey
    func removeListener(listenerKey: ListenerKey)
    func open(address: String, additionalHTTPHeaders: Dictionary<String, String>)
    func open(address: String)
}
