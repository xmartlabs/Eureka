//
//  File.swift
//  
//
//  Created by Dmitry on 31/01/2020.
//

public final class Update {
    public let tags: [String]
    public let updateBlock: (Form) -> Void

    public init(on tags: [String], by updateBlock: @escaping (Form) -> Void) {
        self.tags = tags
        self.updateBlock = updateBlock
    }
}
