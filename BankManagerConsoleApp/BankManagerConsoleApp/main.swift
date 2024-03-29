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
                bankManager.commenceBanking()
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
    
    func bankClosed(customersCount: Int, elapsedTime: Double) {
        print("업무가 마감되었습니다. 오늘 업무를 처리한 고객은 총 \(customersCount)명이며, 총 업무시간은 \(elapsedTime.rounded(toPlaces: 2))초입니다.")
    }
}

let consoleApp = ConsoleApp()

consoleApp.run()
