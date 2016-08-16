//
//  MessageTypes.swift
//  Eureka
//
//  Created by Jingang Liu on 8/16/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import Foundation

public class DictionaryMessage : Equatable {
    var messages:[String:String] = [:]
    func concatenatedMessage() -> String {
        var concatenatedString = ""
        var keys = Array(messages.keys)
        for i in 0 ..< keys.count {
            if i != 0 {
                concatenatedString += "\n"
            }
            concatenatedString += messages[keys[i]] ?? ""
        }
        return concatenatedString
    }
    public init(messages:[String:String]) {
        self.messages = messages
    }
}
public func == (lhs:DictionaryMessage, rhs:DictionaryMessage) -> Bool {
    return lhs.messages == rhs.messages
}