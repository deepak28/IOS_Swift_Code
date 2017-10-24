//
// Created by VIPER

import Foundation

class LoginPresenter: LoginPresenterProtocol
{
    weak var view: LoginViewProtocol?
    var interactor: LoginInteractorInputProtocol?
    var wireFrame: LoginWireFrameProtocol?
    
    init() {}
    
    
    func backOnLandingScreen(){
      wireFrame?.returnToLandingScreen(from: view!)
    }
    func showSettings(){
        wireFrame?.showSettingScreen(from: view!)
    }
    func presenter_LoginCallIn(userNam:String,password:String){
      interactor?.intractor_LoginCallIn(userNam:userNam,password:password)
    }
    
    func presenter_ForgotCallIn(userNam:String){
        interactor?.intractor_ForgotCallIn(userNam: userNam)
    }
    
    func showConfirmPass(userNam:String){
        wireFrame?.ShowConfirmPassView(from: view!,userName:userNam)
    }
    
}

extension LoginPresenter:LoginInteractorOutputProtocol{

    func onPresenterLoginResponse(statusCod:String){
        view?.viewLoginRespons(statusCode:statusCod)
    }
    func presentTabBar(){
      wireFrame?.ShowTabView(from: view!)
    }
    
    func onPresenterForgotResponse(statusCod:String){
        view?.viewForgotRespons(statusCode:statusCod)
    }
}
