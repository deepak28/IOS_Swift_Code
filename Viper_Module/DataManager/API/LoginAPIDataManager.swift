//
// Created by VIPER
// Copyright (c) 2017 VIPER. All rights reserved.
//

import Foundation
import Alamofire
class LoginAPIDataManager: LoginAPIDataManagerInputProtocol
{
    var remoteRequestHandler: LoginAPIDataManagerOutputProtocol?
    init() {}
    func Login(userNam:String,password:String) {
        let deviceID: String = UIDevice.current.identifierForVendor!.uuidString
        UserDefaults.standard.setValue(deviceID, forKey: "auth-deviceId")
      let prm:Parameters  = ["password":password,"deviceId": deviceID,"username":userNam]
        print(prm)
        MasterWebService.sharedInstance.POST_webservice(Url: EndPoints.authLoginURL, prm: prm, background: false,completion: { _result,_statusCode in
            print(_result) as Any
            if _statusCode == 200{
              UserDefaults.standard.setValue(userNam, forKey: "userName")
            }
            self.remoteRequestHandler?.onLoginResponse(status:(_statusCode?.description)!)
         })
       
        
    }
    
    
    func forgotApiCall(email:String){
        let prm:Parameters  = ["username":email]
        MasterWebService.sharedInstance.POST_webservice(Url: EndPoints.recoverPassURL, prm: prm, background: false,completion: { _result,_statusCode in
            print(_result) as Any
            self.remoteRequestHandler?.onForgotResponse(status:(_statusCode?.description)!)
        })
    
    }
}
