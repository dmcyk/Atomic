//
//  UnfairLock.swift
//  TestAtomic
//
//  Created by Damian Malarczyk on 04/04/2018.
//

import Foundation

@available(macOS 10.12, iOS 10.0, *)
final public class _UnfairLock: MututalLock, MututalRawLock {

    public typealias LockType = os_unfair_lock

    @_versioned
    var _lock = os_unfair_lock()

    public init() {}

    @inline(__always)
    public func lock() {
        os_unfair_lock_lock(&_lock)
    }

    @inline(__always)
    public func unlock() {
        os_unfair_lock_unlock(&_lock)
    }
}

final public class UnfairLock: Lock {

    public typealias LockType = os_unfair_lock_s

    @_versioned
    var _lock: Any

    public init() {
        if #available(macOS 10.12, iOS 10.0, *) {
            _lock = _UnfairLock()
        } else {
            _lock = ReadWriteLock()
        }
    }

    @inline(__always)
    public func withReadLock<T>(_ call: () -> T) -> T {
        if #available(macOS 10.12, iOS 10.0, *) {
            return (_lock as! _UnfairLock).withAnyLock(call)
        } else {
            return (_lock as! ReadWriteLock).withReadLock(call)
        }
    }

    @inline(__always)
    public func withWriteLock<T>(_ call: () -> T) -> T {
        if #available(macOS 10.12, iOS 10.0, *) {
            return (_lock as! _UnfairLock).withAnyLock(call)
        } else {
            return (_lock as! ReadWriteLock).withWriteLock(call)
        }
    }
}
