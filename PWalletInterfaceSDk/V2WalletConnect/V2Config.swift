//
//  V2Config.swift
//  PWalletInterfaceSDk
//
//  Created by 郑晨 on 2023/7/19.
//  Copyright © 2023 fzm. All rights reserved.
//

import Foundation
import WalletConnectNetworking
import Web3Wallet
//import Web3Inbox
import BigInt
import SolanaSwift

public class V2Config : NSObject{

    static var projectId:String{
        return "cafd2f18fe867b2f4a894667a6198005"
    }
    
    @objc  func conifgures(){
       
      // 这里
         Networking.configure(projectId: V2Config.projectId, socketFactory:DefaultSocketFactory())
         let metadata = AppMetadata(
             name: "MyDao",
             description: "wallet description",
             url: "MyDao.wallet",
             icons: ["https://avatars.githubusercontent.com/u/37784886"]
         )
         
         Web3Wallet.configure(metadata: metadata, crypto: DefaultCryptoProvider())

//        Web3Inbox.configure(account: Account("eip155:1:0xC313B6F74FcB89147e751220184F0C56D37a210e")!, onSign: onSign(message:), environment: .production)
     }
    

    
//    func onSign(message: String) -> SigningResult {
//        let privateKey = Data(hex: "85f52ec43821c1e2e24a248ee464e8d3f883e460acb0506e1eb6b520eb67ae15")
//        let signer = MessageSignerFactory(signerFactory: DefaultSignerFactory()).create()
//        let signature = try! signer.sign(message: message, privateKey: privateKey, type: .eip191)
//        return .signed(signature)
//    }
}

