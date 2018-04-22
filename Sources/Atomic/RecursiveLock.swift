//
//  RecursiveLock.swift
//  Atomic
//
//  Created by Damian Malarczyk on 22/04/2018.
//

import Foundation

// RWLock is implemented as recursive, through the `EDEADLK` error
// Using only closure syntax gives full control over lock and unlock mechanism
public typealias RecursiveLock = ReadWriteLock
