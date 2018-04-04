//
//  AtomicTests.swift
//  AtomicTests
//
//  Created by damian.malarczyk on 03/12/2017.
//  Copyright © 2017 damian.malarczyk. All rights reserved.
//

import XCTest
@testable import Atomic

@inline(never)
private func sink<T>(_ val: inout T) { }
class TestAtomicTests: XCTestCase {

    func testUnfair() {
        if #available(macOS 10.12, *) {
            executeLockTest(Atomic<Int, UnfairLock>(0))
        }
    }

    func testRW() {
        executeLockTest(Atomic<Int, ReadWriteLock>(0))
    }

    func testMutex() {
        executeLockTest(Atomic<Int, MutexLock>(0))
    }

    func testQueue() {
        executeLockTest(Atomic<Int, DispatchLock>(0))
    }

    private func executeLockTest<T>(_ atomic: Atomic<Int, T>) {
        let dispatchBlockCount = 16
        let iterationCountPerBlock = 1
        // This is an example of a performance test case.
        let queues = [
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive),
            DispatchQueue.global(qos: DispatchQoS.QoSClass.default),
            DispatchQueue.global(qos: DispatchQoS.QoSClass.utility),
        ]

        self.measure {
            let group = DispatchGroup.init()
            for block in 0 ..< dispatchBlockCount {
                group.enter()
                let queue = queues[block % queues.count]
                queue.async(execute: {
                    for _ in 0..<iterationCountPerBlock {
                        atomic.withWriteLock {
                            return $0 + 2 - 1
                        }
                    }
                    group.leave()
                })
            }
            _ = group.wait(timeout: DispatchTime.distantFuture)
        }
    }
}
