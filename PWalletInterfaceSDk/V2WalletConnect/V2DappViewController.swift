//
//  V2DappViewController.swift
//  PWalletInterfaceSDk
//
//  Created by 郑晨 on 2023/7/19.
//  Copyright © 2023 fzm. All rights reserved.
//

import Foundation
import WalletConnectUtils
import Web3Wallet
import Combine
import Web3
import CryptoKit
import PromiseKit
import JKBigInteger
import AlphaWalletFoundation

@objcMembers
class V2DappViewController: UIViewController {
    var localCoin : LocalCoin? // 使用的币
    var btyCoin : LocalCoin? // BTY
    var ethCoin : LocalCoin? // ETH
    var bnbCoin : LocalCoin? // BNB
    // 获取gasprice的节点
    let web3_ethrpc: String  = "https://rpc.flashbots.net"
    let web3_bnbrpc: String = "https://bsc.publicnode.com"
    let web3_btyrpc: String = "https://mainnet.bityuan.com/eth"
    var web3_rpc:String?
    
    var error : NSError?
    var prikey:String? //私钥
    var gsaprice:BigUInt?
    var nonce : BigUInt?
    var isStaye:Bool = false
    enum Errors: Error {
        case notImplemented
    }
    var wcurl : String? // 链接用的url
    var timeOver:Bool = false
    var defaltProposal : Session.Proposal?
    var newSession : Session?
    
    @Published var sessions = [Session]()
    private var disposeBag = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navBar = UINavigationBar.appearance()
        //取消导航栏下的黑线
        navBar.setBackgroundImage(UIImage(), for: .bottom, barMetrics: .default)
        navBar.shadowImage = UIImage()
        navBar.backgroundColor = UIColor.clear
        
        self.view.backgroundColor = UIColor.init(red: 248.0/255.0, green: 248.0/255.0, blue: 251/255.0, alpha: 1.0)
        
        self.title = "WallectConnect"
        self.createView()
        self.setNavBar()
        setupInitialState()
        onScanUri();
         
        NotificationCenter.default.addObserver(self, selector: #selector(exitApp), name: Notification.Name("exitapp"), object: nil)
    }
    
    // 用户退出app之后，自动断开与wallect connect的连接
      func exitApp() {
          self.disconnect()
      }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        NotificationCenter.default.removeObserver(self)
    }
    func onScanUri(){
        guard let uri = WalletConnectURI(string: wcurl!) else {
            // 报错
            self.hideProgress()
            self.showCustomMessage("链接失败，请稍后再试", hideAfterDelay: 2)
            return
        }
        
        self.pair(uri: uri)
    }
    
    func pair(uri:WalletConnectURI) {
        Task.detached(priority: .high) { @MainActor  in
            do {
                try await Web3Wallet.instance.pair(uri: uri)
            }
        }
    }
    
    func setNavBar() {
        var btnBack = UIBarButtonItem()
       
        
        btnBack = UIBarButtonItem(image: #imageLiteral(resourceName: "back_black"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.toBack))
       
        self.navigationItem.leftBarButtonItem = btnBack
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor:UIColor.black,.font:UIFont.systemFont(ofSize: 19)]
    }
    
    func toBack() {
       
        UserDefaults.standard.set(isStaye, forKey: "stay")
        NotificationCenter.default.post(name: NSNotification.Name("stayNotification"), object: nil)
//        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
    func createView() {
        isStaye = false
        let wcIconImgView = UIImageView.init()
        wcIconImgView.image = UIImage.init(named: "wcicon")
        wcIconImgView.frame = CGRect(x: (self.view.frame.size.width - 180) / 2.0, y: (self.view.frame.size.height - 80) / 2.0, width: 60, height: 60)
        let pwalletIconImgView = UIImageView.init()
        pwalletIconImgView.image = UIImage.init(named: "appiconcopy")
        pwalletIconImgView.frame = CGRect(x: (self.view.frame.size.width - 180) / 2.0 + 120, y: (self.view.frame.size.height - 80) / 2.0, width: 60, height: 60)
        
        self.view.addSubview(wcIconImgView)
        self.view.addSubview(pwalletIconImgView)
        
        let load1 = UILabel.init(frame: CGRect(x: wcIconImgView.frame.size.width + wcIconImgView.frame.origin.x + 15, y: wcIconImgView.frame.origin.y + 27, width: 5, height: 5))
        load1.backgroundColor = UIColor(red: 241.0/255.0, green: 241.0/255.0, blue: 241.0/255.0, alpha: 1)
        load1.layer.cornerRadius = 2.5
        
        self.view.addSubview(load1)
        
        let load2 = UILabel.init(frame: CGRect(x: load1.frame.size.width + load1.frame.origin.x + 5, y: load1.frame.origin.y, width: 5, height: 5))
        load2.backgroundColor = UIColor(red: 241.0/255.0, green: 241.0/255.0, blue: 241.0/255.0, alpha: 0.5)
        load2.layer.cornerRadius = 2.5
        
        self.view.addSubview(load2)
        
        let load3 = UILabel.init(frame: CGRect(x: load2.frame.size.width + load2.frame.origin.x + 5, y: load1.frame.origin.y, width: 5, height: 5))
        load3.backgroundColor = UIColor(red: 241.0/255.0, green: 241.0/255.0, blue: 241.0/255.0, alpha: 0.25)
        load3.layer.cornerRadius = 2.5
        
        self.view.addSubview(load3)
       
        let tiplab  = UILabel.init(frame: CGRect(x: 10, y:wcIconImgView.frame.origin.y + wcIconImgView.frame.size.height + 20, width: self.view.frame.size.width - 20, height: 20))
        tiplab.text = "WallectConnect正在连接你的钱包"
        tiplab.textColor = UIColor(red: 142.0/255.0, green: 146.0/255.0, blue: 163.0/255.0, alpha: 1.0)
        tiplab.font = UIFont.systemFont(ofSize: 13)
        tiplab.textAlignment = .center
        
        self.view.addSubview(tiplab)
        
    }
    
    func createAuthview(proposal:Session.Proposal){
         print("我需要先认证")
        self.defaltProposal = proposal // 初始化数据
        for view:UIView in self.view.subviews {
            view.removeFromSuperview()
        }
        timeOver = true
        let navHeight = self.navigationController?.navigationBar.frame.height
        let statusHeight = UIApplication.shared.statusBarFrame.height
        
        let imgView = UIImageView.init()
        imgView.frame = CGRect(x: (self.view.frame.size.width - 60) / 2.0, y: 60 + navHeight! + statusHeight, width: 60, height: 60)
        let imageData = NSData.init(contentsOf: NSURL(string: proposal.proposer.icons.first!)! as URL)
        imgView.image = UIImage.init(data: imageData! as Data)
        self.view.addSubview(imgView)
        
        let tipLab = UILabel.init(frame: CGRect(x: 10, y: imgView.frame.size.height + imgView.frame.origin.y + 12, width: self.view.frame.size.width - 20, height: 21))
        tipLab.text = proposal.proposer.name + "请求连接你的钱包"
        tipLab.textColor = UIColor(red: 51.0/255.0, green: 54.0/255.0, blue: 73.0/255.0, alpha: 1)
        tipLab.font = UIFont.systemFont(ofSize: 15)
        tipLab.textAlignment = .center
        self.view.addSubview(tipLab)
        
        let urlLab = UILabel.init(frame: CGRect(x: 10, y: tipLab.frame.size.height + tipLab.frame.origin.y + 13, width: self.view.frame.size.width - 20, height: 17))
        urlLab.text = proposal.proposer.url
        urlLab.textColor = UIColor(red: 142.0/255.0, green: 146.0/255.0, blue: 163.0/255.0, alpha: 1.0)
        urlLab.font = UIFont.systemFont(ofSize: 12)
        urlLab.textAlignment = .center
        self.view.addSubview(urlLab)
        

        let addressTipLab = UILabel.init(frame: CGRect(x: 16, y: urlLab.frame.size.height + urlLab.frame.origin.y + 34, width: self.view.frame.size.width - 32, height: 50))
        addressTipLab.text = "  · 允许获取当前钱包地址"
        addressTipLab.textColor = UIColor(red: 142.0/255.0, green: 146.0/255.0, blue: 163.0/255.0, alpha: 1.0)
        addressTipLab.font = UIFont.systemFont(ofSize: 14)
        addressTipLab.textAlignment = .left
        addressTipLab.backgroundColor = UIColor.white
        addressTipLab.layer.cornerRadius = 5
        
        self.view.addSubview(addressTipLab)
        
        let signTipLab = UILabel.init(frame: CGRect(x: 16, y: addressTipLab.frame.size.height + addressTipLab.frame.origin.y + 1, width: self.view.frame.size.width - 32, height: 50))
        signTipLab.text = "  · 允许向当前钱包请求签名"
        signTipLab.textColor = UIColor(red: 142.0/255.0, green: 146.0/255.0, blue: 163.0/255.0, alpha: 1.0)
        signTipLab.font = UIFont.systemFont(ofSize: 14)
        signTipLab.textAlignment = .left
        signTipLab.backgroundColor = UIColor.white
        signTipLab.layer.cornerRadius = 5
        
        self.view.addSubview(signTipLab)
        
        
        let supportBtn = UIButton.init(frame: CGRect(x: 10, y: self.view.frame.size.height - 120, width: self.view.frame.size.width - 20, height: 17))
        supportBtn.setTitle("该服务由 WallectConnect 协议支持 >", for: .normal)
        supportBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        supportBtn.setTitleColor(UIColor(red: 142.0/255.0, green: 146.0/255.0, blue: 163.0/255.0, alpha: 1.0), for: .normal)
        self.view.addSubview(supportBtn)
        
        
        let rejectBtn = UIButton.init(frame: CGRect(x: 10, y: self.view.frame.size.height - 80, width: (self.view.frame.size.width - 30)/2, height: 40))
        rejectBtn.setTitle("拒绝", for: .normal)
        rejectBtn.layer.cornerRadius = 5.0
        rejectBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        rejectBtn.backgroundColor = UIColor(red: 225.0/255.0, green: 235.0/255.0, blue: 247.0/255.0, alpha: 1)
        rejectBtn.addTarget(self, action: #selector(rejectConect), for: .touchUpInside)
        rejectBtn.setTitleColor(UIColor(red: 113.0/255.0, green: 144.0/255.0, blue: 1, alpha: 1), for: .normal)
        self.view.addSubview(rejectBtn)
        
        let approveBtn = UIButton.init(frame: CGRect(x: 20 + (self.view.frame.size.width - 30)/2, y: self.view.frame.size.height - 80, width: (self.view.frame.size.width - 30)/2, height: 40))
        approveBtn.setTitle("授权", for: .normal)
        approveBtn.layer.cornerRadius = 5.0
        approveBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        approveBtn.addTarget(self, action: #selector(approveConnect), for: .touchUpInside)
        approveBtn.backgroundColor = UIColor(red: 13.0/255.0, green: 140.0/255.0, blue: 233.0/255.0, alpha: 1)
        self.view.addSubview(approveBtn)
    }
    
    func createConnectView(proposal:Session.Proposal) {
        for view:UIView in self.view.subviews {
            view.removeFromSuperview()
        }
//        self.navigationController?.setNavigationBarHidden(true, animated: true)
        isStaye = true
        let proposer = proposal.proposer
        
        let imgView = UIImageView.init()
        imgView.frame = CGRect(x: (self.view.frame.size.width - 60) / 2.0, y: 60 + 100, width: 60, height: 60)
        let imageData = NSData.init(contentsOf: NSURL(string: proposer.icons.first!)! as URL)
        imgView.image = UIImage.init(data: imageData! as Data)
        self.view.addSubview(imgView)
        
        let tipLab = UILabel.init(frame: CGRect(x: 10, y: imgView.frame.size.height + imgView.frame.origin.y + 12, width: self.view.frame.size.width - 20, height: 25))
        tipLab.text = proposer.name + "已连接你的钱包"
        tipLab.textColor = UIColor(red: 51.0/255.0, green: 54.0/255.0, blue: 73.0/255.0, alpha: 1)
        tipLab.font = UIFont.systemFont(ofSize: 15)
        tipLab.textAlignment = .center
        self.view.addSubview(tipLab)
        
        let urlLab = UILabel.init(frame: CGRect(x: 10, y: tipLab.frame.size.height + tipLab.frame.origin.y + 13, width: self.view.frame.size.width - 20, height: 17))
        urlLab.text = proposer.url
        urlLab.textColor = UIColor(red: 142.0/255.0, green: 146.0/255.0, blue: 163.0/255.0, alpha: 1)
        urlLab.font = UIFont.systemFont(ofSize: 12)
        urlLab.textAlignment = .center
        self.view.addSubview(urlLab)
        
        let contentView = UIView.init(frame: CGRect(x: 10, y: urlLab.frame.size.height + urlLab.frame.origin.y + 50, width: self.view.frame.size.width - 20, height: 60))
        contentView.backgroundColor = UIColor.white
        contentView.layer.cornerRadius = 5.0
        self.view.addSubview(contentView)
        
        let addressTipLab = UILabel.init(frame: CGRect(x: 80, y: 0, width: self.view.frame.size.width - 20 - 50, height: 20))
        addressTipLab.text = self.localCoin?.coin_type
        addressTipLab.textColor = UIColor(red: 142.0/255.0, green: 146.0/255.0, blue: 163.0/255.0, alpha: 1)
        addressTipLab.font = UIFont.systemFont(ofSize: 15)
        addressTipLab.textAlignment = .left
        contentView.addSubview(addressTipLab)
        
        let addressLab = UILabel.init(frame: CGRect(x: 10, y: 0, width: 70, height: 60))
        addressLab.text = "Address"
        addressLab.textColor = UIColor(red: 142.0/255.0, green: 146.0/255.0, blue: 163.0/255.0, alpha: 1)
        addressLab.font = UIFont.systemFont(ofSize: 14)
        addressLab.textAlignment = .left
        contentView.addSubview(addressLab)
        
        
        let addrDetailLab = UILabel.init(frame: CGRect(x: 80, y: 20, width: self.view.frame.size.width - 20 - 80, height: 40))
        addrDetailLab.text = self.localCoin?.coin_address
        addrDetailLab.textColor = UIColor(red: 51.0/255.0, green: 54.0/255.0, blue: 73.0/255.0, alpha: 1)
        addrDetailLab.font = UIFont.systemFont(ofSize: 15)
        addrDetailLab.textAlignment = .left
        addrDetailLab.numberOfLines = 0
        contentView.addSubview(addrDetailLab)
        
        
        let supportBtn = UIButton.init(frame: CGRect(x: 10, y: self.view.frame.size.height - 120, width: self.view.frame.size.width - 20, height: 20))
        supportBtn.setTitle("该服务由 WallectConnect 协议支持 >", for: .normal)
        supportBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        supportBtn.setTitleColor(UIColor(red: 128.0/255.0, green: 128.0/255.0, blue: 128.0/255.0, alpha: 1), for: .normal)
        self.view.addSubview(supportBtn)
        
        
        let disconnectBtn = UIButton.init(frame: CGRect(x: 10, y: self.view.frame.size.height - 80, width: self.view.frame.size.width - 20, height: 40))
        disconnectBtn.setTitle("断开连接", for: .normal)
        disconnectBtn.layer.cornerRadius = 5.0
        disconnectBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        disconnectBtn.backgroundColor = UIColor(red: 254.0/255.0, green: 127.0/255.0, blue: 116.0/255.0, alpha: 1)
        disconnectBtn.addTarget(self, action: #selector(disconnect), for: .touchUpInside)
        disconnectBtn.setTitleColor(UIColor.white, for: .normal)
        self.view.addSubview(disconnectBtn)
    }
    
   
    
    func getGasprice() async throws {
        if self.localCoin?.coin_type == "BNB" {
            self.web3_rpc = web3_bnbrpc
            let web3 = Web3.init(rpcURL: self.web3_rpc!)
            web3.eth.gasPrice { resp in
                print("resp is \(resp)")
                self.gsaprice = resp.result?.quantity
            }
            
            let ethaddress = try! EthereumAddress(rawAddress: (self.localCoin?.coin_address.hexToBytes())!)
            
            web3.eth.getTransactionCount(address:ethaddress, block: .latest) { resp in
                print("ethresp is \(resp)")
                self.nonce = resp.result?.quantity
            }
        }else if self.localCoin?.coin_type == "ETH"{
            self.web3_rpc = web3_ethrpc
            let web3 = Web3.init(rpcURL: self.web3_rpc!)
            web3.eth.gasPrice { resp in
                print("resp is \(resp)")
                self.gsaprice = resp.result?.quantity
            }
            
            let ethaddress = try! EthereumAddress(rawAddress: (self.localCoin?.coin_address.hexToBytes())!)
            
            web3.eth.getTransactionCount(address:ethaddress, block: .latest) { resp in
                print("ethresp is \(resp)")
                self.nonce = resp.result?.quantity
            }
        }else if self.localCoin?.coin_type == "BTY"{
            self.web3_rpc = web3_btyrpc
            let web3 = Web3.init(rpcURL: self.web3_rpc!)
            web3.eth.gasPrice { resp in
                print("resp is \(resp)")
                self.gsaprice = resp.result?.quantity
            }
            self.getbtyNonce()
        }
    }
    
    
    func showAlertWithRequest(request:Request) {
        // 需要输入密码获取私钥
       
        switch request.method {
        case "personal_sign":
//            var dict = NSDictionary.init()
//            let jsonstr = request.params.jsonString
//            let jsonData = jsonstr?.data(using: .utf8)
//            let json = try! JSONSerialization.jsonObject(with: jsonData!, options: .mutableContainers)
//            let arr = json as! Array<Any>
//            dict = ["name":defaltProposal?.proposer.name as Any,
//                    "url":defaltProposal?.proposer.url as Any,
//                    "icon_url":defaltProposal?.proposer.icons.first as Any,
//                    "addr":self.localCoin?.coin_address as Any,
//                    "message":arr[0]]
//            let sheetAlert = DappAlertSheetView.init(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height),
//                                                     with: DappAlertSheetTypeSign,
//                                                     withData: dict as! [AnyHashable : Any],
//                                                     with: self.localCoin!)
//
//            sheetAlert.dappBlock = {(passwdStr:String?) in
//                print("psaawd ",passwdStr as Any)
//                if passwdStr?.count == 0 {
//                    self.showCustomMessage("请输入钱包密码", hideAfterDelay: 2.0)
//
//                }else if passwdStr == "取消" {
//                    Task(priority: .userInitiated) {
//                        try await self.rejectSend(sessionRequest:request)
//                        sheetAlert.dismiss()
//                    }
//                }
//                else{
//                    Task (priority: .userInitiated){
//                        let wallet = PWDataBaseManager.shared().queryWalletIsSelected()
//                        let remebercode = GoFunction.deckey(wallet?.wallet_remembercode, password: passwdStr)
//                        let hdwallet = GoFunction.goCreateHDWallet(self.localCoin?.coin_type, rememberCode: remebercode!)
//                        if hdwallet == nil {
//                            self.showCustomMessage("密码错误", hideAfterDelay: 2.0)
//                            return
//                        }
//                        let prikey = try! hdwallet?.newKeyPriv(0).hexString
//                        self.prikey = prikey
//                        sheetAlert.dismiss()
//
//                    }
//                }
//
//            }
//            sheetAlert.show();
            
            break
        case "eth_signTypedData": break
        case "eth_sendTransaction":
            var dict = NSDictionary.init()
            let jsonstr = request.params.jsonString
            let jsonData = jsonstr?.data(using: .utf8)
            let paramdict = self.dataToDictionary(data: jsonData!)
            let gas =  BigInt(self.sixteenToTen(str: ((paramdict!["gas"] as! String).replacingOccurrences(of: "0x", with: ""))))
            let valueold =  paramdict!["value"] == nil ? "0" : paramdict!["value"]
            
            let value =  valueold as! String == "0" ? 0 : BigInt(self.sixteenToTen(str: ((valueold as! String).replacingOccurrences(of: "0x", with: ""))))
           
            let realGas = Double(gas * BigInt(self.gsaprice!)) / 1000000000000000000.0
            
           
            let paramArray = [["name":"支付信息","info":"转账"],
                              ["name":"收款地址","info":paramdict!["to"]],
                              ["name":"付款地址","info":paramdict!["from"]],
                              ["name":"矿工费","info":realGas]]
            
           
            dict = ["name":defaltProposal?.proposer.name as Any,
                    "url":defaltProposal?.proposer.url as Any,
                    "icon_url":defaltProposal?.proposer.icons.first as Any,
                    "paramArray":paramArray,
                    "value":value]
    //        let showAlert:Bool = UserDefaults.standard.bool(forKey: "showAlert")
    //        if showAlert == true {
    //            return
    //        }
            
            let sheetAlert = DappAlertSheetView.init(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height),
                                                     with: DappAlertSheetTypePay,
                                                     withData: dict as! [AnyHashable : Any],
                                                     with: self.localCoin!)
            
            sheetAlert.dappBlock = {(passwdStr:String?,selectedGas:String?,selectedGasPrice:String?) in
                print("psaawd ",passwdStr as Any)
                if passwdStr?.count == 0 {
                    self.showCustomMessage("请输入钱包密码", hideAfterDelay: 2.0)
                }else if passwdStr == "取消" {
                    Task(priority: .userInitiated) {
                        try await self.rejectSend(sessionRequest:request)
                        sheetAlert.dismiss()
                    }
                    return
                }
                else{
                    Task (priority: .userInitiated){
                        let wallet = PWDataBaseManager.shared().queryWalletIsSelected()
                        let remebercode = GoFunction.deckey(wallet?.wallet_remembercode, password: passwdStr)
                        let hdwallet = GoFunction.goCreateHDWallet(self.localCoin?.coin_chain, rememberCode: remebercode!)
                        if hdwallet == nil {
                            self.showCustomMessage("密码错误", hideAfterDelay: 2.0)
                            return
                        }
                        let prikey = try! hdwallet?.newKeyPriv(0).hexString
                        self.prikey = prikey
                        
                        if self.localCoin?.coin_type == "BTY" {
                            self.signAndSendBtyTran(requestS:request, alert: sheetAlert,selectedGas: selectedGas!,selectedGasPrice: selectedGasPrice!)
                        }else{
                            let result = try self.sign(request: request)
                            try await self.approveSend(sessionRequest: request, result: result)
                            // 结束后，自动获取新的nonce和gasprice
                          
                            sheetAlert.dismiss()
                        }
                    }
                    
                }
            }
            sheetAlert.show(with: self.view);
            break
        case "solana_signTransaction": break
        default: break
           
        }
    }
    
    func sixteenToTen(str:String) -> BigUInt {
        
        
        let value = BigUInt(str, radix: 16) ?? BigUInt()
//        var b:Int = 0
//        b = Int(str.drop0x,radix:16)!
//        let bigInt = JKBigInteger(string: str,andRadix: <#T##Int32#>)
        return value
    }
    
    func dataToDictionary(data:Data) ->Dictionary<String, Any>?{
        do{
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            let arr = json as! Array<Any>
            let dic = arr[0] as! Dictionary<String, Any>
            return dic
        }catch _ {
            print("失败")
            return nil
        }
    }
    
    func rejectConect(){
        Task(priority: .userInitiated) {
            try await onReject()
            isStaye = false
            UserDefaults.standard.set(isStaye, forKey: "stay")
            NotificationCenter.default.post(name: NSNotification.Name("stayNotification"), object: nil)
//            self.navigationController?.popToRootViewController(animated: true)
        }
       
    }
    
    
    func approveConnect() {
        Task(priority: .userInitiated) {
            try await onApprove()
            try await self.getGasprice()
            self.createConnectView(proposal: defaltProposal!)
        }
    }
    
    func disconnect(){
        Task(priority: .userInitiated) {
            try await onDisconnect()
            isStaye = false
            UserDefaults.standard.set(isStaye, forKey: "stay")
            NotificationCenter.default.post(name: NSNotification.Name("stayNotification"), object: nil)
//            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func rejectSend(sessionRequest: Request) async throws {
        try await Web3Wallet.instance.respond(topic: sessionRequest.topic,
                                              requestId: sessionRequest.id,
                                              response: .error(.init(code: 0, message: "error balance")))
    }
    
    func approveSend(sessionRequest:Request, result:AnyCodable) async throws {
        do {
            try await Web3Wallet.instance.respond(topic: sessionRequest.topic,
                                                  requestId: sessionRequest.id,
                                                  response: .response(result))
        } catch {
            throw error
        }
    }
    
}

extension V2DappViewController {
    private func setupInitialState(){
        // 授权使用
        Web3Wallet.instance.sessionProposalPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] session in
                // 这里要去显示连接view
                print("proposal\(session.proposal.pairingTopic)")
                self?.createAuthview(proposal: session.proposal)
            }
            .store(in: &disposeBag)
        
        // 授权之后，topic会变，需要用这个topic断开链接
        Web3Wallet.instance.sessionSettlePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] session in
                self?.newSession = session
                print("session\(session.topic)")
            }
            .store(in: &disposeBag)
        // 交易使用
        Web3Wallet.instance.sessionRequestPublisher
            .receive(on: DispatchQueue.main)
            .sink {[unowned self] (request: Request, context: VerifyContext?) in
                // 显示弹框
                print(request)
                // 获取gasprice和nonce
                Task(priority: .userInitiated) {
                    try await self.getGasprice()
                    self.showAlertWithRequest(request: request)
                }
                
            }
            .store(in: &disposeBag)
        // 网页断开链接
        Web3Wallet.instance.sessionDeletePublisher
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] session in
                // 断开链接,退出页面
                isStaye = false
                UserDefaults.standard.set(isStaye, forKey: "stay")
                NotificationCenter.default.post(name: NSNotification.Name("stayNotification"), object: nil)
//                self.navigationController?.popToRootViewController(animated: true)
            }
            .store(in: &disposeBag)
        
        sessions = Web3Wallet.instance.getSessions()
    }
    
    
}

extension V2DappViewController {
    
    @MainActor
    func onApprove() async throws {
        
        let supportedMethods = Set(defaltProposal!.requiredNamespaces.flatMap { $0.value.methods } + (defaltProposal!.optionalNamespaces?.flatMap { $0.value.methods } ?? []))
        let supportedEvents = Set(defaltProposal!.requiredNamespaces.flatMap { $0.value.events } + (defaltProposal!.optionalNamespaces?.flatMap { $0.value.events } ?? []))
        
        let supportedRequiredChains = defaltProposal!.requiredNamespaces["eip155"]?.chains
        let supportedOptionalChains = defaltProposal!.optionalNamespaces?["eip155"]?.chains ?? []
        let supportedChains = supportedRequiredChains?.union(supportedOptionalChains) ?? []
        let eip = supportedRequiredChains?.first?.description
        var address = ethCoin?.coin_address
        localCoin = ethCoin
        if eip == "eip155:1"{
            address = ethCoin?.coin_address
            localCoin = ethCoin
        }else if eip == "eip155:56"{
            address = bnbCoin?.coin_address
            localCoin = bnbCoin
        }else if eip == "eip155:2999"{
            address = btyCoin?.coin_address
            localCoin = btyCoin
        }
        let supportedAccounts = Array(supportedChains).map { Account(blockchain: $0, address: address!)! }
        
        do {
            let sessionNamespace = try AutoNamespaces.build(sessionProposal: defaltProposal!,
                                                            chains: Array(supportedChains),
                                                            methods: Array(supportedMethods),
                                                            events: Array(supportedEvents),
                                                            accounts: supportedAccounts)
            try await Web3Wallet.instance.approve(proposalId: defaltProposal!.id, namespaces: sessionNamespace)
        } catch {
            print(error)
        }
       
    }

    @MainActor
    func onReject() async throws {
        try await Web3Wallet.instance.reject(proposalId: defaltProposal!.id, reason: .userRejected)
        
    }
    @MainActor
    func onDisconnect() async throws {
        
        try await Web3Wallet.instance.disconnect(topic: newSession!.topic)
        
    }

    func sign(request: Request) throws -> AnyCodable {
        
        switch request.method {
        case "personal_sign":
            return self.personalSign(request.params)

        case "eth_signTypedData":
            return self.signTypedData(request.params)

        case "eth_sendTransaction":
            return self.sendTransaction(request.params)

        case "solana_signTransaction":
            return SOLSigner.signTransaction(request.params)
            
        default:
            throw V2DappViewController.Errors.notImplemented
        }
        
    }
    
    func personalSign(_ params:AnyCodable) -> AnyCodable {
        
        let jsonstr = params.jsonString
        let jsonData = jsonstr?.data(using: .utf8)
        let json = try! JSONSerialization.jsonObject(with: jsonData!, options: .mutableContainers)
        let arr = json as! Array<Any>
        let result = arr[0]
        
        return AnyCodable(any: result)
    }
    
    func signTypedData(_ params:AnyCodable)  -> AnyCodable{
        let result = "0x4355c47d63924e8a72e509b65029052eb6c299d53a04e167c5775fd466751c9d07299936d304c153f6443dfa05f40ff007d72911b6f72307f996231605b915621c"
        return AnyCodable(result)
    }
    
    func sendTransaction(_ params:AnyCodable) -> AnyCodable {
        print(params)
        let jsonstr = params.jsonString
        let jsonData = jsonstr?.data(using: .utf8)
        let paramdict = self.dataToDictionary(data: jsonData!)
        let gas =  BigInt(self.sixteenToTen(str: ((paramdict!["gas"] as! String).replacingOccurrences(of: "0x", with: ""))))
      
        let valueold =  paramdict!["value"] == nil ? "0" : paramdict!["value"]
        let value =  valueold as! String == "0" ? 0 : BigInt(self.sixteenToTen(str: ((valueold as! String).replacingOccurrences(of: "0x", with: ""))))
        let inputData = (paramdict!["data"] as! String).replacingOccurrences(of: "0x", with: "")
        let inputData64 = self.base64Encoding(plainString: inputData)


        let resultJson = ["from":paramdict!["from"],
                          "gas":gas,
                          "gasPrice":Int64(self.gsaprice!),
                          "input":inputData64,
                          "nonce":Int64(self.nonce!),
                          "to":paramdict!["to"],
                          "value":value]
        let resultJsonData = try? JSONSerialization.data(withJSONObject: resultJson, options: [])
        let resultJsonStr = String(data: resultJsonData!, encoding: .utf8)
        print("构造的数据是-----》\(String(describing: resultJsonStr))")
        let txData = WalletapiStringTobyte(resultJsonStr, &error)

        let signData = WalletapiSignData()
        signData.cointype = (self.localCoin?.coin_chain)!
        signData.data = txData
        signData.privKey = self.prikey!
        signData.addressID = 2

        let signTx = WalletapiSignRawTransaction(signData, &error)

        if (error != nil) {
            self.showError(error, hideAfterDelay: 2.0)
            return AnyCodable(signTx)
        }
        let sendTx = WalletapiWalletSendTx()
        sendTx.signedTx = signTx
        sendTx.cointype = signData.cointype
        let util = WalletapiUtil()
        util.node = GoNodeUrl
        sendTx.util = util

        let result = WalletapiSendRawTransaction(sendTx, &error)
        if error != nil{
            self.showError(error, hideAfterDelay: 2.0)
            return AnyCodable(signTx)
        }
        let resultStr = String(data: result!, encoding: .utf8)
        print("send_tran\(String(describing: resultStr))")

        return AnyCodable(result)
    }
    
    
}

extension V2DappViewController.Errors : LocalizedError {
    var errorDescription: String? {
        switch self {
        case .notImplemented:   return "Requested method is not implemented"
        }
    }
}

extension V2DappViewController {
    // base64 编码
    func base64Encoding(plainString:String) -> String {
        
        let plainData =  WalletapiHexTobyte(plainString)
        let base64String = plainData?.base64EncodedString(options: .init(rawValue: 0))
        
        return base64String!
    }
    
    // base64解码
    func base64Decoding(encodedString:String) -> String {
        
        let decodeData = NSData(base64Encoded: encodedString, options: .init(rawValue: 0))
        let decodeString = NSString(data: decodeData! as Data, encoding:String.Encoding.utf8.rawValue)! as String
        
        return decodeString
    }
    
}


extension V2DappViewController {
    // BTY特殊处理
    
    func getbtyNonce() {
        let param = [self.localCoin?.coin_address,"latest"]
        let params = ["id":1,
                      "jsonrpc":"2.0",
                      "method":"eth_getTransactionCount",
                      "params":param] as [String:Any]
        let data = try? JSONSerialization.data(withJSONObject: params,options: [])
        var request = URLRequest(url: URL(string: self.web3_btyrpc)!)
        request.httpMethod = "POST"
        request.httpBody = data
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                print(error.debugDescription)
            }else{
                print(String(data:data!, encoding: String.Encoding.utf8) as Any)
                if let any = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments){
                    let dict : Dictionary = any as! Dictionary<String, Any>
                    let result = dict["result"]
                    let nonce =  Int64(self.sixteenToTen(str: ((result as! String).replacingOccurrences(of: "0x", with: ""))))
                    self.nonce = BigUInt(nonce)
                    
                    print(dict)
                }
                
            }
            
        }
        task.resume()
        
    }
    
    func signAndSendBtyTran(requestS:Request, alert:DappAlertSheetView,selectedGas:String,selectedGasPrice:String) {
        
        let jsonstr = requestS.params.jsonString
        let jsonData = jsonstr?.data(using: .utf8)
        let paramdict = self.dataToDictionary(data: jsonData!)
        let gas =  Int64(selectedGas) == 0 ? Int64(self.sixteenToTen(str: ((paramdict!["gas"] as! String).replacingOccurrences(of: "0x", with: "")))) : Int64(selectedGas)// 如果是自选的，不需要进行转换
      
        let valueold =  paramdict!["value"] == nil ? "0" : paramdict!["value"]
        var value = BigInt(0)
        if valueold as! String == "0x0" || valueold as! String == "0"{
            value = BigInt(0)
        }else{
            value = BigInt(self.sixteenToTen(str: ((valueold as! String).replacingOccurrences(of: "0x", with: ""))))
        }

        let inputData = (paramdict!["data"] as! String).replacingOccurrences(of: "0x", with: "")
        let inputData64 = self.base64Encoding(plainString: inputData)


        let resultJson = ["from":paramdict!["from"],
                          "gas":Int64(gas!),
                          "gasPrice": Double(selectedGasPrice) == 0 ? Int64(self.gsaprice!) : Int64(Double(selectedGasPrice)! * 1000000000),
                          "input":inputData64,
                          "nonce":Int64(self.nonce!),
                          "to":paramdict!["to"],
                          "value":Int64(value)]
        
        let resultJsonData = try? JSONSerialization.data(withJSONObject: resultJson, options: [])
        let resultJsonStr = String(data: resultJsonData!, encoding: .utf8)
        print("构造的数据是-----》\(String(describing: resultJsonStr))")
        let txData = WalletapiStringTobyte(resultJsonStr, &error)

        let signData = WalletapiSignData()
        signData.cointype = "BTYETH"
        signData.data = txData
        signData.privKey = self.prikey!
        signData.addressID = 2

        let signTx = WalletapiSignRawTransaction(signData, &error)
        
        let params = ["id":1,
                      "jsonrpc":"2.0",
                      "method":"eth_sendRawTransaction",
                      "params":[signTx]] as [String:Any]
        let data = try? JSONSerialization.data(withJSONObject: params,options: [])
        var request = URLRequest(url: URL(string: self.web3_btyrpc)!)
        request.httpMethod = "POST"
        request.httpBody = data
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            // 请求结束后，自动获取新的nonce和gasprice
            if error != nil {
                print(error.debugDescription)
            }else{
                print(String(data:data!, encoding: String.Encoding.utf8) as Any)
                Task (priority: .userInitiated){
                    if let any = try?JSONSerialization.jsonObject(with: data!, options: .allowFragments){
                        let dict : Dictionary = any as! Dictionary<String, Any>
                        print(dict)
                        let result = dict["result"] as! String
                        if result.count != 0 {
                            let anyResult = AnyCodable(result)
                            
                            try await self.approveSend(sessionRequest: requestS, result: anyResult)
                            //
                            
                            alert.dismiss()
                        }else{
                            let errorResult = dict["error"] as! Dictionary<String, Any>
                            self.showCustomMessage(errorResult["message"] as? String, hideAfterDelay: 2)
                        }
                        
                    }
                }
                
            }
            
        }
        task.resume()
    }

}


