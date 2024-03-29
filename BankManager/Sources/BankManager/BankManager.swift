//
//  BankManager.swift
//
//
//  Created by Danny, Prism on 3/19/24.
//

import Foundation

public protocol BankManagerDelegate: AnyObject {
    func bankingStarted(customer: Customer)
    func bankingEnded(customer: Customer)
    func bankClosed(customersCount: Int, elapsedTime: Double)
}

public final class BankManager {
    private let loanClerksCount: Int
    private let depositClerksCount: Int
    private var customersCount: Int
    private let bankQueue = BankQueue<Customer>()
    
    public weak var delegate: BankManagerDelegate?
    
    public init(loanClerksCount: Int, depositClerksCount: Int) {
        self.loanClerksCount = loanClerksCount
        self.depositClerksCount = depositClerksCount
        self.customersCount = bankQueue.count
    }
    
    private func enqueueTodaysVisitors() {
        for waitingNumber in 1...Int.random(in: 10...30) {
            guard let randomBanking = Banking.random() else {
                return
            }
            
            let customer = Customer(waitingNumber: waitingNumber, banking: randomBanking)
            bankQueue.enqueue(element: customer)
        }
        
        customersCount = bankQueue.count
    }
    
    public func commenceBanking() {
        enqueueTodaysVisitors()
        
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
                self.delegate?.bankingStarted(customer: customer)
                Thread.sleep(forTimeInterval: customer.banking.requiredTime)
                self.delegate?.bankingEnded(customer: customer)
                
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
        
        self.delegate?.bankClosed(customersCount: customersCount, elapsedTime: bankingElapsedTime)
    }
}
