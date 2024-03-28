//
//  Banking.swift
//
//
//  Created by Danny, Prism on 3/28/24.
//

enum Banking: CaseIterable {
    case loan
    case deposit
    
    var name: String {
        switch self {
        case .loan:
            return "대출"
        case .deposit:
            return "예금"
        }
    }
    
    static func random() -> Banking? {
        var generator = SystemRandomNumberGenerator()
        return Banking.allCases.randomElement(using: &generator)
    }
}
