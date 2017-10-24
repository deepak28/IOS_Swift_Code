//
// Created by VIPER
// Copyright (c) 2017 VIPER. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class LoginView: UIViewController
{
    //MARK: Global Varibales
    var presenter: LoginPresenterProtocol?
    var userName:String?
   
    
    
   //MARK: IB-Outlet
    
   
    @IBOutlet weak var lblForForgotPass: UILabel!
    @IBOutlet weak var ViewForPasswordTxt: UIView!
    @IBOutlet weak var btnForForgotPass: UIButton!
    @IBOutlet weak var btnForLogin: WhiteBorderButton!
    @IBOutlet weak var textFieldForEmail: UITextField!
    @IBOutlet weak var textFieldForPassword: UITextField!
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    
    //MARK: IB-Actions
    @IBAction func ActionOnLoginBtn(_ sender: Any) {
        self.view.endEditing(true)
        let email : String = (textFieldForEmail.text?.stringByRemovingWhitespaces)!
        if  lblForForgotPass.isHidden {
            let pass : String = (textFieldForPassword.text?.stringByRemovingWhitespaces)!
            self.LoginCall(email: email, Pass: pass)
            
        }else {
            self.forgotCall(email:email)
        }
        
    }
    
    @IBAction func ActionOnForgotPassBtn(_ sender: Any) {
        lblForForgotPass.isHidden = false
        ViewForPasswordTxt.isHidden = true
        btnForForgotPass.isHidden = true
        btnForLogin.setTitle("Send password", for: .normal)
        
        

    }
    
    @IBAction func ActionOnBackBtn(_ sender: Any) {
        presenter?.backOnLandingScreen()
    }
    
    //MARK: Custom Methods 
    func LoginCall(email:String ,Pass:String){
        
        if email != "" && Pass != ""{
            if MasterWebService.sharedInstance.isValidEmail(testStr: email){
                      presenter?.presenter_LoginCallIn(userNam:email,password:Pass)
           }else{
                self.view.showToast(message:"Please enter a valid email!")
            }
            
        }else{
         self.view.showToast(message: "All fields are required!")
        }
        
    }
    // forgot password 
    func forgotCall(email:String){
        
        if email != "" {
            if MasterWebService.sharedInstance.isValidEmail(testStr: email){
                presenter?.presenter_ForgotCallIn(userNam: email)
                self.userName = email
            }else{
                self.view.showToast(message:"Please enter a valid email!")
            }
        }else{
            self.view.showToast(message: "Please enter email!")
        }
    
    }
    
    
    
    
}
//login view extention
extension LoginView:LoginViewProtocol {
    
    func viewLoginRespons(statusCode:String){
    print("finally done it ! Status code is " + statusCode)
        if statusCode == "200"{
         self.presenter?.presentTabBar()
        }else{
        self.view.showToast(message: "Login Failed.")
        }
}
    
    func viewForgotRespons(statusCode:String){
        print("finally done it ! Status code is " + statusCode)
        if statusCode == "200"{
               self.presenter?.showConfirmPass(userNam: self.userName!)
        }else if statusCode == "400"{
            self.view.showToast(message: "User is not registered/activated")
        }
    }
   
    
    
    
}
