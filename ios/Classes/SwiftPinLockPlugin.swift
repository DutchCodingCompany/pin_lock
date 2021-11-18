import Flutter
import UIKit

@available(iOS 12.0, *)
public class SwiftPinLockPlugin: NSObject, FlutterPlugin {
    
    internal let registrar: FlutterPluginRegistrar
    private let _overlayViewTag = 1620655620
    private var hideAppContent = false
    private var asset: String? = nil
    
    init(registrar: FlutterPluginRegistrar) {
        self.registrar = registrar
        super.init()
        registrar.addApplicationDelegate(self)
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "pin_lock", binaryMessenger: registrar.messenger())
        let instance = SwiftPinLockPlugin(registrar: registrar)
        registrar.addMethodCallDelegate(instance, channel: channel)
        channel.setMethodCallHandler({(call: FlutterMethodCall, result: FlutterResult)-> Void in
            if (call.method == "setHideAppContent"){
                if let arguments = call.arguments as? Dictionary<String, Any> {
                    if let shouldHide = arguments["shouldHide"] as? NSNumber {
                        instance.hideAppContent = shouldHide.boolValue
                    }
                    if let asset = arguments["iosAsset"] as? String  {
                        instance.asset = asset
                    }
                }
            }
        })
    }
    
    public func applicationDidEnterBackground(_ application: UIApplication) {
        if (hideAppContent) {
            UIApplication.shared.ignoreSnapshotOnNextApplicationLaunch()
            if let window = UIApplication.shared.windows.filter({ (w) -> Bool in
                return w.isHidden == false
            }).first {
                if let existingView = window.viewWithTag(_overlayViewTag) {
                    window.bringSubviewToFront(existingView)
                    return
                } else {
                    var view = UIView()
                    if let asset = asset, let icon = UIImage(named: asset) {
                        let imageView = UIImageView(image: icon)
                        imageView.contentMode = UIView.ContentMode.scaleAspectFill
                        view = imageView
                    }
                    view.frame = window.frame
                    view.tag = _overlayViewTag
                    view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    view.backgroundColor = window.traitCollection.userInterfaceStyle == .dark ? UIColor.black : UIColor.white
                    window.addSubview(view)
                    window.bringSubviewToFront(view)
                    
                    window.snapshotView(afterScreenUpdates: true)
                }
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
