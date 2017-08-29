import Foundation

#if os(iOS)
    import UIKit
#elseif os(OSX)
    import Cocoa
#endif

protocol ConnectionObserver {
    func setUp(onConnect: @escaping () -> (), onDisconnect: @escaping () -> ())
}

internal final class ConnectionObserverImpl: ConnectionObserver {
    
    private let appStateCenter: VKNotificationCenter
    private let reachabilityCenter: VKNotificationCenter
    private let reachability: VKReachability
    
    private let activeNotificationName: Notification.Name
    private let inactiveNotificationName: Notification.Name
    private let reachabilityNotificationName: Notification.Name
    
    private var appIsActive = true
    private var onConnect: (() -> ())?
    private var onDisconnect: (() -> ())?
    
    private var observers = [NSObjectProtocol?]()
    
    init(
        appStateCenter: VKNotificationCenter,
        reachabilityCenter: VKNotificationCenter,
        reachability: VKReachability,
        activeNotificationName: Notification.Name,
        inactiveNotificationName: Notification.Name,
        reachabilityNotificationName: Notification.Name
        ) {
        self.appStateCenter = appStateCenter
        self.reachabilityCenter = reachabilityCenter
        self.reachability = reachability
        self.activeNotificationName = activeNotificationName
        self.inactiveNotificationName = inactiveNotificationName
        self.reachabilityNotificationName = reachabilityNotificationName

    }
    
    public func setUp(onConnect: @escaping () -> (), onDisconnect: @escaping () -> ()) {
        self.onConnect = onConnect
        self.onDisconnect = onDisconnect
        
        setUpAppStateObservers()
        setUpReachabilityObserver()
    }
    
    private func setUpAppStateObservers() {
        let becomeActiveObserver = appStateCenter.addObserver(
            forName: activeNotificationName,
            object: self,
            queue: nil,
            using: { [weak self] notification in
                self?.handleAppActive(notification)
            }
        )
        
        let resignActiveObserver = appStateCenter.addObserver(
            forName: inactiveNotificationName,
            object: self,
            queue: nil,
            using: { [weak self] notification in
                self?.handleAppInnactive(notification)
            }
        )
        
        observers.append(contentsOf: [becomeActiveObserver, resignActiveObserver])
    }
    
    private func setUpReachabilityObserver() {
        
        let reachabilityObserver = appStateCenter.addObserver(
            forName: ReachabilityChangedNotification,
            object: self,
            queue: nil,
            using: { [weak self] notification in
                self?.handleReachabilityChange(notification)
            }
        )
        
        observers.append(reachabilityObserver)
        
        _ = try? reachability.startNotifier()
    }
    
    private func handleReachabilityChange(_ notification: Notification) {
        guard let reachability = notification.object as? VKReachability else { return }
        guard appIsActive == true else { return }

        if reachability.isReachable {
            onConnect?()
        }
        else {
            onDisconnect?()
        }
    }
    
    private func handleAppActive(_ notification: Notification) {
        guard appIsActive == false else { return }
        appIsActive = true
        onConnect?()
    }
    
    private func handleAppInnactive(_ notification: Notification) {
        guard appIsActive == true else { return }
        appIsActive = false
        onDisconnect?()
    }
    
    deinit {
        for observer in observers {
            if let observer = observer {
                NotificationCenter.default.removeObserver(observer)
            }
        }
    }
}
