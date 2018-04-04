//
//  UnfairLock.swift
//  TestAtomic
//
//  Created by Damian Malarczyk on 04/04/2018.
//

import Foundation

@available(macOS 10.12, *)
@available(iOS 10.0, *)
final public class UnfairLock: MututalLock {

    public typealias LockType = os_unfair_lock_s
    private var lock: os_unfair_lock_s

    public init() {
        lock = os_unfair_lock_s()
    }

    public func withAnyLock<T>(_ call: () -> T) -> T {
        os_unfair_lock_lock(&lock)
        let val = call()
        os_unfair_lock_unlock(&lock)
        return val
    }
}
