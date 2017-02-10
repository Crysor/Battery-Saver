//
//  SystemeInfo.swift
//  Battery Saver
//
//  Created by Jérémy Kerbidi on 31/10/2016.
//  Copyright © 2016 Jérémy Kerbidi. All rights reserved.
//

import Foundation

class CellSection {
    
    var LabelInfo: String!
    var LabelData: String!
    
    init(info: String, data: String) {
        self.LabelInfo = info
        self.LabelData = data
    }
}
