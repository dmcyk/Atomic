//
//  RWLock.swift
//  TestAtomicTests
//
//  Created by damian.malarczyk on 03/12/2017.
//  Copyright © 2017 damian.malarczyk. All rights reserved.
//

import Foundation

@_versioned
func acquire(lock: UnsafeMutablePointer<pthread_rwlock_t>, isWrite: Bool) -> UnsafeMutablePointer<pthread_rwlock_t>? {
    let acquired: Int32 = {
        if isWrite {
            return pthread_rwlock_wrlock(lock)
        }

        // Too many locks acquired, need to wait until available
        var attr: Int32 = pthread_rwlock_rdlock(lock)
        while attr == EAGAIN {
            usleep(1000 * 50) // sleep for 50 milliseconds
            attr = pthread_rwlock_rdlock(lock)
        }

        return attr
    }()

    assert(acquired != EINVAL, "passing uninitialized lock")

    if acquired == EDEADLK { // trying to acquire lock on already locked thread, so there's no need to unlock - RecusiveLock behaviour
        return nil
    }
    return lock
}

@_versioned
func unlock(lock: UnsafeMutablePointer<pthread_rwlock_t>?) {
    if let lock = lock {
        pthread_rwlock_unlock(lock)
    }
}

/// Implemented as `recursive` lock, through check for `EDEADLK` message
/// In case case there's no need to unlock such lock
final public class ReadWriteLock: Lock {

    public typealias LockType = pthread_rwlock_t
    @_versioned
    var lock: pthread_rwlock_t

    public init() {
        self.lock = pthread_rwlock_t()
        pthread_rwlock_init(&self.lock, nil)
    }

    deinit {
        pthread_rwlock_destroy(&self.lock)
    }

    @inline(__always)
    public func withReadLock<T>(_ call: () -> T) -> T {
        let lock = acquire(lock: &self.lock, isWrite: false)
        let val = call()
        unlock(lock: lock)
        return val
    }

    @inline(__always)
    public func withWriteLock<T>(_ call: () -> T) -> T {
        let lock = acquire(lock: &self.lock, isWrite: true)
        let val = call()
        unlock(lock: lock)
        return val
    }
}
