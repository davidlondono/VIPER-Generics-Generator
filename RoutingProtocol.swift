//
//  RoutingProtocol.swift
//  VIPER Generics
//
//  Created by David Alejandro (davidlondono) on 1/7/16.
//  Copyright © 2016 David Alejandro (davidlondono). All rights reserved.
//

import UIKit

protocol RoutingProtocolBase: class {
    typealias InteractorType: InteractorProtocolBase
    typealias PresenterType: PresenterProtocolBase
    typealias ViewControllerType: ViewControllerProtocolBase
    
    weak var viewController: ViewControllerType! {get set}
    weak var interactor: InteractorType! {get set}
    weak var presenter: PresenterType! {get set}
    
    //function for loading the view
    func loadView() -> ViewControllerType
    
    //extra config executed after the viewControllerConfigured()
    func extraConfigViewController()
    
    init()
}

extension RoutingProtocolBase{
    
    func viewControllerConfigured() throws -> ViewControllerType{
        let newViewController = loadView()
        let newPresenter = PresenterType()
        let newInteractor = InteractorType()
        
        presenter = newPresenter
        interactor = newInteractor
        viewController = newViewController
        
        if let newInteractor = newInteractor as? PresenterType.InteractorType{
            presenter.interactor = newInteractor
        } else {
            throw RoutingProtocolError.wrongInteractorProtocolPresenter
        }
        if let viewController = viewController as? PresenterType.ViewControllerType{
            presenter.viewController = viewController
        } else {
            
            throw RoutingProtocolError.wrongViewProtocolPresenter
        }
        if let selfRouting = self as? PresenterType.RoutingType {
            presenter.routing = selfRouting
        } else {
            throw RoutingProtocolError.wrongRoutingProtocolPresenter
        }
        
        
        if let presenter = presenter as? InteractorType.PresenterType{
            interactor.presenter = presenter
        } else {
            throw RoutingProtocolError.wrongPresenterProtocolInteractor
        }
        
        if let presenter = presenter as? ViewControllerType.PresenterType {
            viewController.presenter = presenter
        } else {
            throw RoutingProtocolError.wrongPresenterProtocolView
        }
        
        self.extraConfigViewController()
        
        return viewController

    }
    func presentScene(router: Self, animated: Bool = true, completition: (() -> Void)?) throws {
        guard let viewController = try viewControllerConfigured() as? UIViewController else {
            return
        }
        if let routerController = router.viewController as? UIViewController{
            routerController.presentViewController(viewController, animated: animated, completion: completition)
        }
    }
    func extraConfigViewController() {
        //optional function
    }
}

enum RoutingProtocolError: ErrorType {
    case wrongInteractorProtocolPresenter
    case wrongViewProtocolPresenter
    case wrongPresenterProtocolInteractor
    case wrongPresenterProtocolView
    case wrongRoutingProtocolPresenter
}

protocol ViewProtocolPresenterBase: class {
}


protocol ViewControllerProtocolBase: ViewProtocolPresenterBase {
    typealias PresenterType = protocol<PresenterProtocolViewBase>
    var presenter:PresenterType! {get set}
}

protocol PresenterProtocolViewBase: class {
}
extension PresenterProtocolViewBase {
    func viewWillAppear(){}
    func viewDidAppear(){}
    func viewWillDisappear(){}
    func viewDidDisappear(){}
    func viewDidLoad(){}
}
protocol PresenterProtocolInteractorBase: class {
}
protocol PresenterProtocolBase: PresenterProtocolViewBase,PresenterProtocolInteractorBase {
    typealias InteractorType = protocol<InteractorProtocolPresenterBase>
    typealias ViewControllerType = protocol<ViewProtocolPresenterBase>
    typealias RoutingType
    
    var viewController: ViewControllerType? {get set}
    var interactor: InteractorType! {get set}
    var routing: RoutingType! {get set}
    init()
}

protocol InteractorProtocolPresenterBase: class {
}
protocol InteractorProtocolBase:InteractorProtocolPresenterBase {
    typealias PresenterType = protocol<PresenterProtocolInteractorBase>
    
    var presenter:PresenterType? {get set}
    init()
}



protocol myPresenterView: PresenterProtocolViewBase{
    
}
protocol myViewPresener: ViewProtocolPresenterBase{
    
}

protocol myInteractorPresener: InteractorProtocolPresenterBase{
    
}
class myPresenter: PresenterProtocolBase {
    typealias ViewControllerType = myViewPresener
    
    weak var viewController: myViewPresener?
    var interactor: myInteractorPresener!
    var routing: AnyObject!
    
    required init(){
        
    }
}
class myView: ViewControllerProtocolBase {
    
    var presenter:myPresenterView!
}


class BaseViewController<P:PresenterProtocolViewBase>: ViewControllerProtocolBase{
    //typealias PresenterType = P
    var presenter:P!
}

