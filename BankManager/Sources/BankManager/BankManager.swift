//
//  BankManager.swift
//
//
//  Created by Danny, Prism on 3/19/24.
//

import Foundation

public struct BankManager {
    private let loanClerksCount: Int
    private let depositClerksCount: Int
    private let bankQueue = BankQueue<Customer>()
    
    public init(loanClerksCount: Int, depositClerksCount: Int) {
        self.loanClerksCount = loanClerksCount
        self.depositClerksCount = depositClerksCount
    }
    
    private func enqueueTodaysVisitors() {
        for waitingNumber in 1...Int.random(in: 10...30) {
            guard let randomBanking = Banking.random() else {
                return
            }
            
            let customer = Customer(waitingNumber: waitingNumber, banking: randomBanking)
            bankQueue.enqueue(element: customer)
        }
    }
    
    public func commenceBanking() {
        enqueueTodaysVisitors()
        let numberOfCustomer = bankQueue.count
        
        let loanConcurrentLimitingSemaphore = DispatchSemaphore(value: loanClerksCount)
        let depositConcurrentLimitingSemaphore = DispatchSemaphore(value: depositClerksCount)
        
        let bankingGroup = DispatchGroup()
        
        let bankingStartTime = DispatchTime.now()
        while !bankQueue.isEmpty {
            guard let customer = bankQueue.dequeue() else { return }
            
            switch customer.banking {
            case .loan:
                loanConcurrentLimitingSemaphore.wait()
            case .deposit:
                depositConcurrentLimitingSemaphore.wait()
            }
            
            DispatchQueue.global().async(group: bankingGroup) {
                print("\(customer.waitingNumber)번 고객 업무 시작")
                Thread.sleep(forTimeInterval: 0.7)
                print("\(customer.waitingNumber)번 고객 업무 완료")
                
                switch customer.banking {
                case .loan:
                    loanConcurrentLimitingSemaphore.signal()
                case .deposit:
                    depositConcurrentLimitingSemaphore.signal()
                }
            }
        }
        
        bankingGroup.wait()
        
        let bankingEndTime = DispatchTime.now()
        let bankingElapsedTime = Double(bankingEndTime.uptimeNanoseconds - bankingStartTime.uptimeNanoseconds) / 1_000_000_000
        print("업무가 마감되었습니다. 오늘 업무를 처리한 고객은 총 \(numberOfCustomer)명이며, 총 업무시간은 \(bankingElapsedTime.rounded(toPlaces: 2))초입니다.")
    }
}
