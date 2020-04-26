//
//  GameViewModel.swift
//  ColorGame
//
//  Created by ezou on 2020/4/26.
//  Copyright © 2020 ezou. All rights reserved.
//

import Combine
import SwiftUI

class GameViewModel: ObservableObject {
    
    @Published
    private(set) var level: Int = 1
    
    @Published
    private(set) var remaingTimeInterval: TimeInterval = Constant.DEFAULT_DURATION
    
    private(set) var length: Int = Constant.DEFAULT_LENGTH
        
    private var brightness: Double = 0.0
    
    private var answer: (Int, Int) = (0, 0)
        
    private var lastTimestamp: Date = .init()
    
    private var cancellables: Set<AnyCancellable> = []
    
    private var timerSubscription: AnyCancellable?
    
    private var timer: AnyPublisher<Date, Never> {
        Timer.publish(every: 0.1, on: .main, in: .common).autoconnect().eraseToAnyPublisher()
    }
    
    lazy var color: Color = {
        randomColor()
    }()
    
    var nextLevel: Int {
        let offset = length + 1 - 2
        return 5 + (offset - 1) * offset * 5 / 2
    }
    
    var isFinished: Binding<Bool> {
        Binding<Bool>(
            get: { self.remaingTimeInterval <= 0.0 },
            set: {
                guard !$0 else { return }
                self.reset()
            }
        )
    }
    
    var failureSubject: PassthroughSubject<Void, Never> = .init()
    
    func randomColor() -> Color {
        let hue = Double.random(in: 0.0...1.0)
        let saturation = Double.random(in: 0.3...0.7)
        let brightness = Double.random(in: 0.3...0.5)
        
        self.brightness = brightness
        
        return Color(hue: hue, saturation: saturation, brightness: brightness)
    }
    
    func createAnswer() -> (Int, Int) {
        func randomLength() -> Int {
            Int.random(in: 0..<length)
        }
        return (randomLength(), randomLength())
    }
    
    func getBrightness(x: Int, y: Int) -> Double {
        guard x == answer.0, y == answer.1 else {
            return brightness
        }
        
        return brightness * (0.1 * Double(level) / 100.0 + 0.9)
    }
    
    func startIfNeeded() {
        guard timerSubscription == nil else { return }
        timerSubscription = timer.sink { [unowned self] timer in
            self.remaingTimeInterval -= 0.1
            if self.remaingTimeInterval <= 0.0 {
                self.timerSubscription?.cancel()
            }
        }
    }
    
    func reset() {
        timerSubscription = nil
        remaingTimeInterval = Constant.DEFAULT_DURATION
        length = Constant.DEFAULT_LENGTH
        level = 1
    }
    
    func submit(x: Int, y: Int) {
        startIfNeeded()
        
        guard x == answer.0, y == answer.1 else {
            return failureSubject.send()
        }
        
        answer = createAnswer()
        
        if level == nextLevel {
            length += 1
        }
        
        if level % 5 == 0 {
            color = randomColor()
        }
        
        remaingTimeInterval += max(0.0, 3.0 + lastTimestamp.timeIntervalSinceNow)
        lastTimestamp = .init()
        
        level += 1
    }
}
