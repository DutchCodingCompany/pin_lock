import Flutter
import UIKit

@available(iOS 12.0, *)
public class SwiftPinLockPlugin: NSObject, FlutterPlugin {
    
    internal let registrar: FlutterPluginRegistrar
    private let _overlayViewTag = 1620655620
    
    init(registrar: FlutterPluginRegistrar) {
        self.registrar = registrar
        super.init()
        registrar.addApplicationDelegate(self)
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "pin_lock", binaryMessenger: registrar.messenger())
        let instance = SwiftPinLockPlugin(registrar: registrar)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    
    public func applicationWillResignActive(_ application: UIApplication) {
        UIApplication.shared.ignoreSnapshotOnNextApplicationLaunch()
        if let window = UIApplication.shared.windows.filter({ (w) -> Bool in
            return w.isHidden == false
        }).first {
            if let existingView = window.viewWithTag(_overlayViewTag) {
                window.bringSubviewToFront(existingView)
                return
            } else {
                let colorView = UIView(frame: window.bounds);
                colorView.tag = _overlayViewTag
                colorView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                colorView.backgroundColor = window.traitCollection.userInterfaceStyle == .dark ? UIColor.black : UIColor.white
                window.addSubview(colorView)
                window.bringSubviewToFront(colorView)
                
                window.snapshotView(afterScreenUpdates: true)
            }
        }
    }
    
    public func applicationDidBecomeActive(_ application: UIApplication) {
        if let window = UIApplication.shared.windows.filter({ (w) -> Bool in
            return w.isHidden == false
        }).first, let view = window.viewWithTag(_overlayViewTag) {
            UIView.animate(withDuration: 0.3, animations: {
                view.alpha = 0.0
            }, completion: { finished in
                view.removeFromSuperview()
            })
        }
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    }
}
