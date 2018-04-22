//
//  AtomicBox.swift
//  TestAtomic
//
//  Created by Damian Malarczyk on 04/04/2018.
//

import Foundation

public protocol Lock: class {

    associatedtype LockType

    init()
    func withReadLock<T>(_ call: () -> T) -> T
    func withWriteLock<T>(_ call: () -> T) -> T
}

public protocol RawLock {

    func lockRead()
    func lockWrite()
    func unlock()
}

public protocol MututalLock: Lock {

    func withAnyLock<T>(_ call: () -> T) -> T
}

public extension MututalLock {

    @inline(__always)
    public func withReadLock<T>(_ call: () -> T) -> T {
        return withAnyLock(call)
    }

    @inline(__always)
    public func withWriteLock<T>(_ call: () -> T) -> T {
        return withAnyLock(call)
    }
}

public protocol MututalRawLock: RawLock {

    func lock()
}

public extension MututalRawLock {

    @inline(__always)
    public func lockRead() {
        lock()
    }

    @inline(__always)
    public func lockWrite() {
        lock()
    }
}


public extension MututalLock where Self: MututalRawLock {

    @inline(__always)
    func withAnyLock<T>(_ call: () -> T) -> T {
        lock()
        let val = call()
        unlock()
        return val
    }
}
