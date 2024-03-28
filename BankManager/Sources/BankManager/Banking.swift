//
//  Banking.swift
//
//
//  Created by Danny, Prism on 3/28/24.
//

enum Banking: CaseIterable {
    case loan
    case deposit
    
    static func random() -> Banking? {
        var generator = SystemRandomNumberGenerator()
        return Banking.allCases.randomElement(using: &generator)
    }
}
