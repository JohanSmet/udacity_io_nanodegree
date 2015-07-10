//
//  LoginService.swift
//  On The Map
//
//  Created by Johan Smet on 03/07/15.
//  Copyright (c) 2015 Justcode.be. All rights reserved.
//

import Foundation
import FBSDKLoginKit

class LoginService {
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // nested types
    //
    
    enum LoginType {
       case LoginNotDone
       case LoginViaUdacity
       case LoginViaFacebook
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // variables
    //
    
    private static var loginType : LoginType = .LoginNotDone
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // public interface
    //
    
    class func loginViaUdacity(email : String, password : String, completionHandler : (error : String?) -> Void) {
        
        if loginType != .LoginNotDone {
            return completionHandler(error: NSLocalizedString("serAlreadyLoggedIn", comment:"Login impossible: already logged in"))
        }
        
        UdacityApiClient.instance().createSessionUdacity(email, password: password) { error in
            if error == nil {
                self.loginType = .LoginViaUdacity
            }
            completionHandler(error: error)
        }
    }
    
    class func loginViaFacebook(completionHandler : (error : String?) -> Void) {
        
        if loginType != .LoginNotDone {
            return completionHandler(error: NSLocalizedString("serAlreadyLoggedIn", comment:"Login impossible: already logged in"))
        }
     
        if FBSDKAccessToken.currentAccessToken() != nil {
            return completeFacebookLogin(FBSDKAccessToken.currentAccessToken().tokenString, completionHandler: completionHandler)
        }
        
        FBSDKLoginManager().logInWithReadPermissions(["public_profile"]) { result, error in
            if error != nil {
                FBSDKLoginManager().logOut()
                completionHandler(error: error.localizedFailureReason)
            } else if result.isCancelled {
                completionHandler(error: NSLocalizedString("serFacebookCancelled", comment: "Facebook-login cancelled"))
            } else {
                let fbToken = result.token.tokenString
                self.completeFacebookLogin(fbToken, completionHandler: completionHandler)
            }
        }
    }
    
    class func completeFacebookLogin(token : String, completionHandler : (error : String?) -> Void) {
       
        UdacityApiClient.instance().createSessionFacebook(token) { error in
            if error == nil {
                self.loginType = .LoginViaFacebook
            }
            completionHandler(error: error)
        }
    }
    
    class func logout(completionHandler : (error : String?) -> Void) {
       
        switch loginType {
            case .LoginNotDone :
                completionHandler(error: NSLocalizedString("serNotLoggedIn", comment: "Logout impossible: not logged in"))
            case .LoginViaUdacity :
                logoutViaUdacity(completionHandler)
            case .LoginViaFacebook :
                logoutViaFacebook(completionHandler)
        }
        
    }
    
    class func logoutViaUdacity(completionHandler : (error : String?) -> Void) {
        UdacityApiClient.instance().deleteSession(UdacityApiClient.instance().sessionId) { error in
            if error == nil {
                self.loginType = .LoginNotDone
            }
            completionHandler(error: error)
        }
    }
    
    class func logoutViaFacebook(completionHandler : (error : String?) -> Void) {
        FBSDKLoginManager().logOut()
        self.loginType = .LoginNotDone
        completionHandler(error: nil)
    }
    
}