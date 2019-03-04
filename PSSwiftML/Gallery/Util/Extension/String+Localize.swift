//
//  String+Localize.swift
//  PSSwiftyML
//
//  Created by Aaron on 2019/1/23.
//  Copyright © 2019 Aaron. All rights reserved.
//

import Foundation

extension String {
    
    /// Localized
    ///
    /// - Parameter string: Default value to return
    /// - Returns: Localized String
    func localized(string: String) -> String {
        let localizedString = NSLocalizedString(self, comment: "")
        return localizedString == self ? string : localizedString
    }
}
