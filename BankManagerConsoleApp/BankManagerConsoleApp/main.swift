//
//  BankManagerConsoleApp - main.swift
//  Created by yagom. 
//  Copyright © yagom academy. All rights reserved.
// 

import Foundation
import BankManager

final class ConsoleApp: BankManagerDelegate {
    var bankManager: BankManager
    
    init() {
        bankManager = BankManager(loanClerksCount: 1, depositClerksCount: 2)
        bankManager.delegate = self
    }
    
    func run() {
        while true {
            print("1 : 은행개점")
            print("2 : 종료")
            print("입력 : ", terminator: "")
            
            guard let inputString = readLine() else {
                break
            }
            
            guard let inputInt = Int(inputString),
                  let menu = BankMenu(rawValue: inputInt) else {
                continue
            }
            
            switch menu {
            case .commence:
                let bankingStartTime = DispatchTime.now()
                
                bankManager.commenceBanking()
                
                let bankingEndTime = DispatchTime.now()
                let bankingElapsedTime = Double(bankingEndTime.uptimeNanoseconds - bankingStartTime.uptimeNanoseconds) / 1_000_000_000
                
                bankManager.printClosingMessage(elapsed: bankingElapsedTime)
            case .exit:
                exit(0)
            }
        }
    }
    
    func bankingStarted(customer: Customer) {
        print("\(customer.waitingNumber)번 고객 \(customer.banking.name)업무 시작")
    }
    
    func bankingEnded(customer: Customer) {
        print("\(customer.waitingNumber)번 고객 \(customer.banking.name)업무 종료")
    }
}

let consoleApp = ConsoleApp()

consoleApp.run()
