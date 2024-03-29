//
//  Banking.swift
//
//
//  Created by Danny, Prism on 3/28/24.
//

public enum Banking: CaseIterable {
    case loan
    case deposit
    
    public var name: String {
        switch self {
        case .loan:
            return "대출"
        case .deposit:
            return "예금"
        }
    }
    
    var requiredTime: Double {
        switch self {
        case .loan:
            return 1.1
        case .deposit:
            return 0.7
        }
    }
    
    static func random() -> Banking? {
        var generator = SystemRandomNumberGenerator()
        return Banking.allCases.randomElement(using: &generator)
    }
}
