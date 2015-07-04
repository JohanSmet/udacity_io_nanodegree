//
//  LoginService.swift
//  On The Map
//
//  Created by Johan Smet on 03/07/15.
//  Copyright (c) 2015 Justcode.be. All rights reserved.
//

import Foundation

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
            completionHandler(error: "Login impossible: already logged in")
            return
        }
        
        UdacityApiClient.instance().createSession(email, password: password) { error in
            if error == nil {
                self.loginType = .LoginViaUdacity
            }
            completionHandler(error: error)
        }
    }
    
    class func loginViaFacebook(completionHandler : (error : String?) -> Void) {
        
    }
    
    class func logout(completionHandler : (error : String?) -> Void) {
       
        switch loginType {
            case .LoginNotDone :
                completionHandler(error: "Logout impossible: not logged in")
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
    }
    
}