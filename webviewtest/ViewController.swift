//
//  ViewController.swift
//  webviewtest
//
//  Created by Alessandro Bellotti on 25/06/2020.
//  Copyright © 2020 Alessandro Bellotti. All rights reserved.
//

import UIKit
import WebKit
import AVFoundation

class ViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {
    
    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       AVAudioSession.sharedInstance().requestRecordPermission({ (granted) -> Void in
               if !granted
               {
                let microphoneAccessAlert = UIAlertController(title: NSLocalizedString("recording_mic_access",comment:""), message: NSLocalizedString("recording_mic_access_message",comment:""), preferredStyle: UIAlertController.Style.alert)

                let okAction = UIAlertAction(title: NSLocalizedString("OK",comment:""), style: UIAlertAction.Style.default, handler: { (alert: UIAlertAction!) -> Void in
                    UIApplication.shared.canOpenURL(NSURL(string: UIApplication.openSettingsURLString)! as URL)
                   })


                let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel",comment:""), style: UIAlertAction.Style.cancel, handler: { (alert: UIAlertAction!) -> Void in

                   })
                   microphoneAccessAlert.addAction(okAction)
                   microphoneAccessAlert.addAction(cancelAction)
                self.present(microphoneAccessAlert, animated: true, completion: nil)
                   return
               }
           });
        
        let url = URL(string: "https://www.onlinemictest.com/")!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
        webView.evaluateJavaScript("callback({id: \((Any).self), status: 'success', args: ...})", completionHandler: nil)

    }

    override func loadView() {
        let contentController = WKUserContentController()
        contentController.add(self, name: "callbackHandler")
        let script = try! String(contentsOf: Bundle.main.url(forResource: "WebRTC", withExtension: "js")!, encoding: String.Encoding.utf8)
        contentController.addUserScript(WKUserScript(source: script, injectionTime: WKUserScriptInjectionTime.atDocumentStart, forMainFrameOnly: true))

        let config = WKWebViewConfiguration()
        config.userContentController = contentController

        webView = WKWebView(frame: CGRect.zero, configuration: config)
        webView.navigationDelegate = self
        view = webView
        

    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "callbackHandler" {
            print(message.body)
            // make native calls to the WebRTC framework here
        }
    }
}

