//
// Created by VIPER
// Copyright (c) 2017 VIPER. All rights reserved.
//

import UIKit

class LoginWireFrame: LoginWireFrameProtocol
{
        
    class func createLoginModule() -> UIViewController {
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "LoginVC")
        if let view = viewController as? LoginView {
            let presenter: LoginPresenterProtocol & LoginInteractorOutputProtocol = LoginPresenter()
            let interactor: LoginInteractorInputProtocol & LoginAPIDataManagerOutputProtocol = LoginInteractor()
            let APIDataManager: LoginAPIDataManagerInputProtocol = LoginAPIDataManager()
            let localDataManager: LoginLocalDataManagerInputProtocol = LoginLocalDataManager()
            let wireFrame: LoginWireFrameProtocol = LoginWireFrame()
            view.presenter = presenter
            presenter.view = view
            presenter.wireFrame = wireFrame
            presenter.interactor = interactor
            interactor.presenter = presenter
            interactor.APIDataManager = APIDataManager
            interactor.localDatamanager = localDataManager
            APIDataManager.remoteRequestHandler = interactor
            return viewController
        }
        return UIViewController()
    }
   
    
    func returnToLandingScreen(from view: LoginViewProtocol){
        if let sourceView = view as? UIViewController {
            sourceView.navigationController?.popViewController(animated: true)
        }
    }
    
    func showSettingScreen(from view: LoginViewProtocol){
          let SettingVC = SettingWireFrame.createSettingModule()
        if let sourceView = view as? UIViewController {
            sourceView.navigationController?.pushViewController(SettingVC, animated: true)
        }
    }
    func ShowTabView(from view: LoginViewProtocol){
        let tabBar = TabBarWireFrame.createTabBarModule()
        if let sourceView = view as? UIViewController {
            sourceView.navigationController?.pushViewController(tabBar, animated: true)
        }
    }
    
    func ShowConfirmPassView(from view: LoginViewProtocol,userName:String){
        let ConfirmPasswordVC = ConfirmPasswordWireFrame.createConfirmPasswordModule(userNam:userName,comeFromSignUp:false)
        if let sourceView = view as? UIViewController {
            sourceView.navigationController?.pushViewController(ConfirmPasswordVC, animated: true)
        }
    }
    
    
    static var mainStoryboard: UIStoryboard {
        return UIStoryboard(name: "Main", bundle: Bundle.main)
    }
}
