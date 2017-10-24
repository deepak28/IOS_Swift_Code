
import UIKit

protocol LoginViewProtocol: class
{
    var presenter: LoginPresenterProtocol? { get set }
    func viewLoginRespons(statusCode:String)
    func viewForgotRespons(statusCode:String)
    /**
    * Add here your methods for communication PRESENTER -> VIEW
    */
}

protocol LoginWireFrameProtocol: class
{
    //static func presentLoginModule(fromView view: AnyObject)
     static func createLoginModule() -> UIViewController
     func returnToLandingScreen(from view: LoginViewProtocol)
     func showSettingScreen(from view: LoginViewProtocol)
     func ShowTabView(from view: LoginViewProtocol)
     func ShowConfirmPassView(from view: LoginViewProtocol,userName:String)
    /**
    * Add here your methods for communication PRESENTER -> WIREFRAME
    */
}

protocol LoginPresenterProtocol: class
{
    var view: LoginViewProtocol? { get set }
    var interactor: LoginInteractorInputProtocol? { get set }
    var wireFrame: LoginWireFrameProtocol? { get set }
    func backOnLandingScreen()
    func showSettings()
    func presenter_LoginCallIn(userNam:String,password:String)
    func presenter_ForgotCallIn(userNam:String)
    func presentTabBar()
    func showConfirmPass(userNam:String)
    /**
    * Add here your methods for communication VIEW -> PRESENTER
    */
}

protocol LoginInteractorOutputProtocol: class
{
    func onPresenterLoginResponse(statusCod:String)
    func onPresenterForgotResponse(statusCod:String)
    /**
    * Add here your methods for communication INTERACTOR -> PRESENTER
    */
}



protocol LoginInteractorInputProtocol: class
{
    var presenter: LoginInteractorOutputProtocol? { get set }
    var APIDataManager: LoginAPIDataManagerInputProtocol? { get set }
    var localDatamanager: LoginLocalDataManagerInputProtocol? { get set }
    func intractor_LoginCallIn(userNam:String,password:String)
    func intractor_ForgotCallIn(userNam:String)
    /**
    * Add here your methods for communication PRESENTER -> INTERACTOR
    */
}

protocol LoginDataManagerInputProtocol: class
{
    /**
    * Add here your methods for communication INTERACTOR -> DATAMANAGER
    */
}

protocol LoginAPIDataManagerInputProtocol: class
{
    var remoteRequestHandler: LoginAPIDataManagerOutputProtocol? { get set }
    func Login(userNam:String,password:String)
    func forgotApiCall(email:String)
    /**
    * Add here your methods for communication INTERACTOR -> APIDATAMANAGER
    */
}
protocol LoginAPIDataManagerOutputProtocol: class {
    // REMOTEDATAMANAGER -> INTERACTOR
    func onLoginResponse(status:String)
    func onForgotResponse(status:String)
    
}


protocol LoginLocalDataManagerInputProtocol: class
{
    /**
    * Add here your methods for communication INTERACTOR -> LOCALDATAMANAGER
    */
}
