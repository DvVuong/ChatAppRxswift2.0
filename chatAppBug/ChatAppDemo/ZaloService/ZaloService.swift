//
//  ZaloService.swift
//  ChatAppDemo
//
//  Created by BeeTech on 23/12/2022.
//

import Foundation
import ZaloSDK

class ZaloService {
    
    static var shared = ZaloService()
    
    func login(_ vc: SiginViewController, completed:@escaping (String, String, String, String) -> Void) {
        AuthenUtils.shared.renewPKCECode()
        ZaloSDK.sharedInstance().authenticateZalo(with: ZAZaloSDKAuthenTypeViaWebViewOnly, parentController: vc, codeChallenge: AuthenUtils.shared.getCodeChallenge(), extInfo: Constant.EXT_INFO) {[weak self] (response) in
            self?.onAuthenticateComplete(with: response)
            
            AuthenUtils.shared.getAccessToken { token in
                guard let token = token else {return}
                ZaloSDK.sharedInstance().getZaloUserProfile(withAccessToken: token) { (response) in
                    let data =  response?.data as? [String: Any] ?? [:]
                    let email = data["id"] as? String ?? ""
                    let name = data["name"] as? String ?? ""
                    let id = data["id"] as? String ?? ""
                    let pictureData: [String: Any] = data["picture"] as? [String: Any] ?? [:]
                    let pictureUrl: [String: Any] = pictureData["data"] as? [String: Any] ?? [:]
                    let url = pictureUrl["url"] as? String ?? ""
                    
                    completed(email, name, id, url)
                }
            }
        }
    }
    
    func logoutZalo() {
        AuthenUtils.shared.logout()
    }
    
    func onAuthenticateComplete(with response: ZOOauthResponseObject?) {
        if response?.isSucess == true {
            getAccessTokenFromOAuthCode(response?.oauthCode)
        } else if let response = response,
             response.errorCode != -1001 { // not cancel
           return
        }
    }
    
    private func getAccessTokenFromOAuthCode(_ oauthCode: String?) {
        ZaloSDK.sharedInstance().getAccessToken(withOAuthCode: oauthCode, codeVerifier: AuthenUtils.shared.getCodeVerifier()) { (tokenResponse) in
            AuthenUtils.shared.saveTokenResponse(tokenResponse)
        }
    }

    
}

