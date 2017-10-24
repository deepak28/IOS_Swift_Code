// Created by VIPER



import Foundation



class LoginInteractor: LoginInteractorInputProtocol
{
    weak var presenter: LoginInteractorOutputProtocol?
    var APIDataManager: LoginAPIDataManagerInputProtocol?
    var localDatamanager: LoginLocalDataManagerInputProtocol?
    
    init() {}
    func intractor_LoginCallIn(userNam:String,password:String)  {
        APIDataManager?.Login(userNam:userNam,password:password)
    }
    
    func intractor_ForgotCallIn(userNam:String)  {
        APIDataManager?.forgotApiCall(email: userNam)
    }
    
}

extension LoginInteractor: LoginAPIDataManagerOutputProtocol{
    func onLoginResponse(status:String){
           presenter?.onPresenterLoginResponse(statusCod:status)
    }
    
    func onForgotResponse(status:String){
        presenter?.onPresenterForgotResponse(statusCod:status)
    }
}
