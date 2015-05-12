//
//  ViewController.swift
//  AOS Order Checker
//
//  Created by Wai Man Chan on 5/12/15.
//
//

import Cocoa
import WebKit

class ViewController: NSViewController {

    @IBOutlet var webView: WebView?
    var oldResult: [String] = []
    var resultInit = false
    
    override func webView(sender: WebView!, didFinishLoadForFrame frame: WebFrame!) {
        
        let addrJS = "document.location.href"
        let addr = sender.stringByEvaluatingJavaScriptFromString(addrJS)
        
        if ((addr as NSString).containsString("sign_in")) {
            //Not login yet
        } else if (addr == "https://secure2.store.apple.com/us/signout") {
            self.webView?.mainFrameURL = "https://secure2.store.apple.com/us/order/list?hist=90"
        } else {
            
            let checker_JS = "document.getElementsByClassName(\"sb-heading\").length"
            let result = sender.stringByEvaluatingJavaScriptFromString(checker_JS)
            if (result == "0") {
                //No order
                let alert = NSAlert()
                alert.messageText = "No order found"
                alert.informativeText = "I can't find any order in this account. Please try log into another account"
                alert.runModal()
                
                //Logout first
                self.webView?.mainFrameURL = "https://secure2.store.apple.com/us/signout"
                usleep(1000*1000)
            } else {
                //Login with orders
                let numberOfOrder = (result as NSString).integerValue
                var i = 0
                var newResult = [String](count: numberOfOrder, repeatedValue: "")
                for(; i < numberOfOrder; i++) {
                    let fetcher = "document.getElementsByClassName(\"sb-heading\")["+String(i)+"].getElementsByTagName(\"h3\")[0].getElementsByTagName(\"span\")[0].innerHTML"
                    newResult[i] = sender.stringByEvaluatingJavaScriptFromString(fetcher)
                }
                
                //Check orders status
                if (resultInit && oldResult != newResult) {
                    //Not equal
                    let notification = NSUserNotification()
                    notification.title = "Order status change"
                    notification.subtitle = "Your order status has changed"
                    
                    NSUserNotificationCenter.defaultUserNotificationCenter().removeAllDeliveredNotifications()
                    NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
                }
                oldResult = newResult
                resultInit = true
                
                //Set refresh timer
                NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: "refresh:", userInfo: nil, repeats: false)
            }
            
        }
    }
    
    func refresh(timer: NSTimer) {
        webView?.mainFrame.reload()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.webView?.mainFrameURL = "https://secure2.store.apple.com/us/order/list?hist=90"
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

