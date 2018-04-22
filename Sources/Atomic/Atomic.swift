//
//  Atomic.swift
//  TestAtomicTests
//
//  Created by damian.malarczyk on 03/12/2017.
//  Copyright © 2017 damian.malarczyk. All rights reserved.
//

import Foundation

public final class Atomic<T, K: Lock> {

    @_versioned
    let lock = K()
    @_versioned
    var _value: T

    @inline(__always)
    public init(_ value: T) {
        _value = value
    }

    @inline(__always)
    public func write(_ value: T) {
        lock.withWriteLock {
            _value = value
        }
    }

    @inline(__always)
    public func read() -> T {
        return lock.withReadLock {
            return _value
        }
    }

    @inline(__always)
    public func withWriteLock<E>(_ call: (inout T) -> E) -> E {
        return lock.withWriteLock {
            return call(&_value)
        }
    }

    @inline(__always)
    public func withReadLock<E>(_ call: (T) -> E) -> E {
        return lock.withReadLock {
            return call(_value)
        }
    }
}
