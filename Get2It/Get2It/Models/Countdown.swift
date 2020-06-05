//
//  Countdown.swift
//  Get2It
//
//  Created by John Kouris on 6/4/20.
//  Copyright © 2020 John Kouris. All rights reserved.
//

import Foundation

class Countdown {
    
    weak var delegate: CountdownDelegate?
    
    var duration: TimeInterval
    
    var timeRemaining: TimeInterval {
        if let stopDate = stopDate {
            let timeRemaining = stopDate.timeIntervalSinceNow
            return timeRemaining
        } else {
            return 0
        }
    }
    
    private var timer: Timer?
    private var stopDate: Date?
    private(set) var state: CountdownState
    
    init() {
        timer = nil
        stopDate = nil
        duration = 0
        state = .reset
    }
    
    func start() {
        cancelTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true, block: updateTimer(timer:))
        stopDate = Date(timeIntervalSinceNow: duration)
        state = .started
    }
    
    func reset() {
        stopDate = nil
        cancelTimer()
        state = .reset
    }
    
    func cancelTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateTimer(timer: Timer) {
        
        if let stopDate = stopDate {
            let currentTime = Date()
            if currentTime <= stopDate {
                delegate?.countdownDidUpdate(timeRemaining: timeRemaining)
            } else {
                state = .finished
                cancelTimer()
                self.stopDate = nil
                delegate?.countdownDidFinish()
            }
        }
    }
}
