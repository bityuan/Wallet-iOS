// Copyright © 2023 Stormbird PTE. LTD.

import AlphaWalletAddress

@available(iOS 13.0, *)
public protocol AssetDefinitionStoreProtocol: TokenScriptStatusResolver {
    var features: TokenScriptFeatures { get }

    subscript(contract: AlphaWallet.Address) -> String? { get }
    subscript(url: URL) -> String? { get }
    func isOfficial(contract: AlphaWallet.Address) -> Bool
    func isCanonicalized(contract: AlphaWallet.Address) -> Bool
    func getXmlHandler(for key: AlphaWallet.Address) -> PrivateXMLHandler?
    func set(xmlHandler: PrivateXMLHandler?, for key: AlphaWallet.Address)
    func getXmlHandler(forAttestationAtURL url: URL) -> PrivateXMLHandler?
    func set(xmlHandler: PrivateXMLHandler?, forAttestationAtURL url: URL)
    func getBaseXmlHandler(for key: String) -> PrivateXMLHandler?
    func setBaseXmlHandler(for key: String, baseXmlHandler: PrivateXMLHandler?)
    func baseTokenScriptFile(for tokenType: TokenType) -> XMLFile?
    func invalidateSignatureStatus(forContract contract: AlphaWallet.Address)

    var assetAttributeResolver: AssetAttributeResolver { get }
}
