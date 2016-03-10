//
//  FormatterConformance.swift
//  Eureka
//
//  Created by Martin Barreto on 2/24/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import Foundation


public protocol FormatterConformance: class {
    var formatter: NSFormatter? { get set }
    var useFormatterDuringInput: Bool { get set }
    var useFormatterOnDidBeginEditing: Bool? { get set }
}
