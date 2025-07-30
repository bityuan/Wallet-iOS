//
//  ScriptMessageProxy.swift
//  PWalletInterfaceSDk
//
//  Created by 郑晨 on 2023/9/5.
//  Copyright © 2023 fzm. All rights reserved.
//

import Foundation
import WebKit
import JavaScriptCore
///Reason for this class: https://stackoverflow.com/questions/26383031/wkwebview-causes-my-view-controller-to-leak
public final class ScriptMessageProxy: NSObject, WKScriptMessageHandler {

    private weak var delegate: WKScriptMessageHandler?

    public init(delegate: WKScriptMessageHandler) {
        self.delegate = delegate
        super.init()
    }

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        delegate?.userContentController(userContentController, didReceive: message)
    }
}







