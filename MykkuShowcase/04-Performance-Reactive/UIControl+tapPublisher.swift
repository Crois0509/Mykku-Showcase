//
//  UIControl+tapPublisher.swift
//  MYKKU Core Showcase
//
//  Created by Jang Sang-gyeong on 11/17/25.
//

import UIKit
import Combine

public extension UIControl {
    
    /// UIButton 등의 UIControl 객체에서 중복 탭 방지가 내장된 Combine 스트림 프로퍼티
    /// - Default: `UIControl.Event = .touchUpInside`
    /// - 내부적으로 `throttle(for: 1.0, scheduler: RunLoop.main, latest: false)`를 탑재하여
    ///   최초 탭 이후 1초 내 발생하는 연속 터치(중복 API 호출 / 중복 화면 Push)를 원천 차단
    var tapPublisher: AnyPublisher<Void, Never> {
        return controlPublisher(for: .touchUpInside)
            .throttle(for: 1.0, scheduler: RunLoop.main, latest: false)
            .map { _ in }
            .eraseToAnyPublisher()
    }
    
    func controlPublisher(for event: UIControl.Event) -> UIControl.EventPublisher {
        return UIControl.EventPublisher(control: self, event: event)
    }
    
    /// UIControl.Event를 방출하는 커스텀 Combine Publisher
    struct EventPublisher: Publisher {
        public typealias Output = UIControl
        public typealias Failure = Never
        
        let control: UIControl
        let event: UIControl.Event
        
        public func receive<S>(subscriber: S) where S: Subscriber, Never == S.Failure, UIControl == S.Input {
            let subscription = EventSubscription(control: control, event: event, subscriber: subscriber)
            subscriber.receive(subscription: subscription)
        }
    }
    
    /// EventPublisher와 Subscriber 연결을 담당하는 Subscription
    fileprivate final class EventSubscription<EventSubscriber: Subscriber>: Subscription, @unchecked Sendable
    where EventSubscriber.Input == UIControl, EventSubscriber.Failure == Never {
        
        let control: UIControl
        let event: UIControl.Event
        var subscriber: EventSubscriber?
        
        init(control: UIControl, event: UIControl.Event, subscriber: EventSubscriber?) {
            self.control = control
            self.event = event
            self.subscriber = subscriber
            
            DispatchQueue.main.async { [weak self, control, event] in
                guard let self else { return }
                control.addTarget(self, action: #selector(self.eventDidOccur), for: event)
            }
        }
        
        func request(_ demand: Subscribers.Demand) { }
        
        func cancel() {
            subscriber = nil
            DispatchQueue.main.async { [weak self, control, event] in
                guard let self else { return }
                control.removeTarget(self, action: #selector(self.eventDidOccur), for: event)
            }
        }
        
        @MainActor
        @objc func eventDidOccur() {
            _ = subscriber?.receive(control)
        }
    }
}
