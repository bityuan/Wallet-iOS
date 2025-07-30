//
//  DAPPBrowser.swift
//  PWalletInterfaceSDk
//
//  Created by 郑晨 on 2023/9/5.
//  Copyright © 2023 fzm. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import JavaScriptCore
import AlphaWalletFoundation
import AlphaWalletLogger
import Combine
import TrustKeystore
import AlphaWalletCore
import Commons
import WalletConnectKMS
import Web3

@objcMembers
public class BrowserViewController: UIViewController {

    
    typealias DecisionHandler = (WKNavigationActionPolicy) -> Void
    typealias DecidePolicy = (navigationAction: WKNavigationAction, decisionHandler: DecisionHandler)
    
    var webUrl:String?
    var btyCoin:LocalCoin?
    
    private let serversProvider: ServersProvidable? = nil
    private var cancellable = Set<AnyCancellable>()
//    let server = RPCServer(withMagicLink: URL(string: "https://mainnet.bityuan.com/eth")!)
    var wallet:Wallet?
    var address = PWUtils.getEthBtyAddress()
    let decidePolicy = PassthroughSubject<BrowserViewController.DecidePolicy,Never>()
    
    static let userClient: String = "AlphaWallet" + "/" + (Bundle.main.versionNumber ?? "") + " 1inchWallet"
    lazy var webView : WKWebView = {
        let webview = WKWebView(frame: .init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height), configuration: config)
        webview.allowsBackForwardNavigationGestures = true
        webview.translatesAutoresizingMaskIntoConstraints = false
        webview.navigationDelegate = self
        
        return webview
    }()
    
    lazy var config : WKWebViewConfiguration = {
        let server = RPCServer.custom(CustomRPC(chainID: 2999,
                                                nativeCryptoTokenName: "BTY",
                                                chainName: "BitYuan Mainnet",
                                                symbol: "BTY",
                                                rpcEndpoint: "https://mainnet.bityuan.com/eth",
                                                explorerEndpoint: "https://www.bityuan.com",
                                                etherscanCompatibleType: RPCServer.EtherscanCompatibleType.blockscout,
                                                isTestnet: false))
        let address = AlphaWallet.Address(uncheckedAgainstNullAddress: PWUtils.getEthBtyAddress())
        let config = WKWebViewConfiguration.make(forType: .dappBrowser(server), address: address!, messageHandler: ScriptMessageProxy(delegate: self))
//        let config = WKWebViewConfiguration.make(forServer: "https://mainnet.bityuan.com/eth", address: PWUtils.getEthBtyAddress(), messageHandler: ScriptMessageProxy(delegate: self))
        config.websiteDataStore = WKWebsiteDataStore.default()
         return config
     }()
   
    @objc public func signPersonalMessage(message:String,prikey:String) async -> String? {

      // 开始
        let messageData = message.data(using: .utf8)
        let prefix = "\u{19}Ethereum Signed Message:\n\(messageData!.count)".data(using: .utf8)!
        let sha3Data = prefix + messageData!
        let hash = sha3Data.sha3(.keccak256)
        let data = try? EthereumSigner().sign(hash: hash, withPrivateKey: WalletapiHexTobyte(prikey)!)
        let hex = WalletapiBytes2Hex(data)
        
        return hex
    }
    
  
    
    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.tintColor = .blue
        progressView.trackTintColor = .clear
        return progressView
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(webView)
        injectUserAgent()
        webView.addSubview(progressView)
        webView.bringSubviewToFront(progressView)
        self.navigationController?.navigationBar.isHidden = false
        self.decidePolicy
            .sink { [weak self] in
            self?.handle(decidePolicy: $0)}
            .store(in: &cancellable)

        NSLayoutConstraint.activate([
            webView.anchorsConstraint(to: view),
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: webView.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: webView.trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 2)
        ])
        view.backgroundColor = .white
        
        self.goTo(url: URL(string: self.webUrl!)!)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        self.goTo(url: URL(string: self.webUrl!)!)
    }
    
    private func injectUserAgent() {
        webView.evaluateJavaScript("navigator.userAgent") { [weak self] result, _ in
            guard let strongSelf = self, let currentUserAgent = result as? String else { return }
            strongSelf.webView.customUserAgent = currentUserAgent + " " + BrowserViewController.userClient
        }
    }
    
    func goTo(url: URL) {
        infoLog("[Browser] Loading URL: \(url.absoluteString)…")
        webView.load(URLRequest(url: url))
    }

    func notifyFinish(callbackId: Int, value: Swift.Result<DappCallback, JsonRpcError>) {
        switch value {
        case .success(let result):
            webView.evaluateJavaScript("executeCallback(\(callbackId), null, \"\(result.value.object)\")") { result, error in
                infoLog("[webviewcall]:\(String(describing: result)),\(String(describing: error))")
            }
        case .failure(let error):
            webView.evaluateJavaScript("executeCallback(\(callbackId), {message: \"\(error.message)\", code: \(error.code)}, null)")
        }
    }

}

extension BrowserViewController: WKNavigationDelegate {
    
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
       
    }

    public func  webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
       
    }

    public func  webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        infoLog("[Browser] navigation with error: \(error)")
        
    }

    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        infoLog("[Browser] provisional navigation with error: \(error)")
        
    }

    public func  webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decidePolicy.send((navigationAction,decisionHandler))
    }
    

    private func handle(decidePolicy: BrowserViewController.DecidePolicy) {
        infoLog("[Browser] decidePolicyFor url: \(String(describing: decidePolicy.navigationAction.request.url?.absoluteString))")

        guard let url = decidePolicy.navigationAction.request.url, let scheme = url.scheme else {
            decidePolicy.decisionHandler(.allow)
            return
        }
        let app = UIApplication.shared
        if ["tel", "mailto"].contains(scheme), app.canOpenURL(url) {
            app.open(url)
            decidePolicy.decisionHandler(.cancel)
            return
        }

        //TODO extract `DeepLink`, if reasonable
        if url.host == "aw.app" && url.path == "/wc", let components = URLComponents(url: url, resolvingAgainstBaseURL: false), components.queryItems.isEmpty {
            infoLog("[Browser] Swallowing URL and doing a no-op, url: \(url.absoluteString)")
            decidePolicy.decisionHandler(.cancel)
            return
        }

        if DeepLink.supports(url: url) {
            decidePolicy.decisionHandler(.cancel)
            return
        }

        decidePolicy.decisionHandler(.allow)
    }
}

extension BrowserViewController: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let commands = DappAction.fromMessage(message)
        print("\(message.body)");
        
//        let server = RPCServer.custom(CustomRPC(chainID: 2999,
//                                                nativeCryptoTokenName: "BTY",
//                                                chainName: "BitYuan Mainnet",
//                                                symbol: "BTY",
//                                                rpcEndpoint: "https://mainnet.bityuan.com/eth",
//                                                explorerEndpoint: "https://www.bityuan.com",
//                                                etherscanCompatibleType: RPCServer.EtherscanCompatibleType.blockscout,
//                                                isTestnet: false))
//
//        let provider = RpcBlockchainProvider(server: server, analytics: AnalyticsService(), params: BlockchainParams.defaultParams(for: server))
        switch commands {
        case .eth(let command):
            switch command.name {
            case .signTransaction: break
            case .sendTransaction:
                let callbackId = commands?.id
                let from = command.object["from"]?.value ?? ""
                let to = command.object["to"]?.value ?? ""
                let value: String? = command.object["value"]?.value
                let gas: String? = command.object["gas"]?.value;
                let data = command.object["data"]?.value ?? ""
                
                break
            case .signMessage:break
            case .signPersonalMessage:break
            case .signTypedMessage:break
            case .ethCall:
                let from = command.object["from"]?.value ?? ""
                let alphafrom = AlphaWallet.Address(uncheckedAgainstNullAddress: from)
                let to = command.object["to"]?.value ?? ""
                let alphato = AlphaWallet.Address(uncheckedAgainstNullAddress: to)
                let data = command.object["data"]?.value ?? ""
                let value: String? = command.object["value"]?.value
                let callbackId = commands?.id
                let servers = RPCServer.custom(CustomRPC(chainID: 2999,
                                                        nativeCryptoTokenName: "BTY",
                                                        chainName: "BitYuan Mainnet",
                                                        symbol: "BTY",
                                                        rpcEndpoint: "https://mainnet.bityuan.com/eth",
                                                        explorerEndpoint: "https://www.bityuan.com",
                                                        etherscanCompatibleType: RPCServer.EtherscanCompatibleType.blockscout,
                                                        isTestnet: false))
//                self.btyethCall(from: from, to: to, data: data, callBlackId: callbackId!)
                let provider = RpcBlockchainProvider(server: servers, analytics: AnalyticsService(), params: BlockchainParams.defaultParams(for: servers))
//                self.ethcall(from: alphafrom, to: alphato, value: value, data: data, provider: provider)
//                    .sink {[weak self] result in
////                        guard case .failure(let error) = result else { return }
////
////                        if case JSONRPCError.responseError(let code, let message, _) = error.embedded {
////                            self!.notifyFinish(callbackId: callbackId!, value: .failure(.init(code: code, message: message)))
////                        } else {
////                            //TODO better handle. User didn't cancel
////                            self!.notifyFinish(callbackId: callbackId!, value: .failure(.responseError))
////                        }
//                    } receiveValue: { [weak self] value in
//                        let callback = DappCallback(id: callbackId!, value: .ethCall(value))
//                        self!.notifyFinish(callbackId: callbackId!, value: .success(callback))
//                    }
//                    .store(in: &cancellable)
                break
            case .unknown:break
                
            }
        case .walletAddEthereumChain(_):break
        case .walletSwitchEthereumChain(_):break
        case .none:
            break
        }
    }
 
    func ethcall(from:AlphaWallet.Address?,to:AlphaWallet.Address?,value:String?,data:String?,provider:BlockchainProvider) -> AnyPublisher<String, PromiseError>{
        return provider.call(from: from, to: to, value: value, data: data!)
            .receive(on: RunLoop.main)
            .mapError{PromiseError(error: $0)}
            .eraseToAnyPublisher()
    }
    
   
}




