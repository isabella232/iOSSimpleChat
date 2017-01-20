//
//  MainViewController.swift
//  Push
//
//  Created by Jordan Zucker on 1/9/17.
//  Copyright © 2017 PubNub. All rights reserved.
//

import UIKit
import PubNub
import CoreData

class MainViewController: UIViewController {
    
    private var mainViewContext = 0
    
//    let client: PubNub
    
    var stackView: UIStackView!
    var pushTokenLabel: UILabel!
    var pushChannelsButton: UIButton!
    let pushChannelsButtonPlaceholder = "Tap here to add push channels"
    let pushTokenLabelPlaceholder = "No push token currently"
    
    let fetchRequest: NSFetchRequest<Result> = {
        let request: NSFetchRequest<Result> = Result.fetchRequest()
        let creationDateSortDescriptor = NSSortDescriptor(key: #keyPath(Result.creationDate), ascending: false)
        request.sortDescriptors = [creationDateSortDescriptor]
        return request
    }()
    
    var consoleView: ClientConsoleView!
    
    override func loadView() {
        let bounds = UIScreen.main.bounds
        var topPadding = UIApplication.shared.statusBarFrame.height
        if let navBarHeight = navigationController?.navigationBar.frame.height {
            topPadding += navBarHeight
        }
        let stackViewFrame = CGRect(x: bounds.origin.x, y: bounds.origin.y + topPadding, width: bounds.size.width, height: bounds.size.height - topPadding)
        stackView = UIStackView(frame: stackViewFrame)
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        let backgroundView = UIView(frame: bounds)
        backgroundView.addSubview(stackView)
        self.view = backgroundView
        self.view.setNeedsLayout()
    }
    
    required init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.title = "Push!"
        pushTokenLabel = UILabel(frame: .zero)
        pushTokenLabel.backgroundColor = .red
        pushTokenLabel.textAlignment = .center
        pushTokenLabel.forceAutoLayout()
        stackView.addArrangedSubview(pushTokenLabel)
        pushChannelsButton = UIButton(type: .custom)
        guard let pushBackgroundImage = UIImage(color: .cyan) else {
            fatalError("Couldn't create one color UIImage!")
        }
        pushChannelsButton.setBackgroundImage(pushBackgroundImage, for: .normal)
        pushChannelsButton.addTarget(self, action: #selector(pushChannelsButtonPressed(sender:)), for: .touchUpInside)
        stackView.addArrangedSubview(pushChannelsButton)
        consoleView = ClientConsoleView(fetchRequest: fetchRequest)
        stackView.addArrangedSubview(consoleView)
        
        let pushTokenLabelVerticalConstraints = NSLayoutConstraint(item: pushTokenLabel, attribute: .height, relatedBy: .equal, toItem: stackView, attribute: .height, multiplier: 0.10, constant: 0)
        let pushChannelsButtonVerticalConstraints = NSLayoutConstraint(item: pushChannelsButton, attribute: .height, relatedBy: .equal, toItem: stackView, attribute: .height, multiplier: 0.25, constant: 0)
        
        NSLayoutConstraint.activate([pushChannelsButtonVerticalConstraints, pushTokenLabelVerticalConstraints])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    func pushChannelsButtonPressed(sender: UIButton) {
        let viewContext = DataController.sharedController.persistentContainer.viewContext
        let pushChannelsAlertController = DataController.sharedController.fetchCurrentUser().alertControllerForPushChannels(in: viewContext)
        present(pushChannelsAlertController, animated: true)
    }
    
    // MARK: - KVO
    
    // Properties
    
    func pushChannelsButtonTitle() -> String {
        var finalTitle: String? = nil
        DataController.sharedController.persistentContainer.viewContext.performAndWait {
            finalTitle = (DataController.sharedController.fetchCurrentUser().pushChannelsString ?? self.pushChannelsButtonPlaceholder)
        }
        return finalTitle!
    }
    
    func pushTokenTitle() -> String {
        var finalTitle: String? = nil
        DataController.sharedController.persistentContainer.viewContext.performAndWait {
            finalTitle = (DataController.sharedController.fetchCurrentUser().pushToken?.debugDescription ?? self.pushTokenLabelPlaceholder)
        }
        return finalTitle!
    }
    
    func updatePushChannelsButton() {
        let title = pushChannelsButtonTitle()
        DispatchQueue.main.async {
            self.pushChannelsButton.setTitle(title, for: .normal)
            self.pushChannelsButton.setNeedsLayout()
        }
    }
    
    func updatePushTokenLabel() {
        let title = pushTokenTitle()
        DispatchQueue.main.async {
            self.pushTokenLabel.text = title
            self.pushTokenLabel.setNeedsLayout()
        }
    }
    
    var currentUser: User? {
        didSet {
            if let existingOldValue = oldValue {
                existingOldValue.removeObserver(self, forKeyPath: #keyPath(User.pushChannels), context: &mainViewContext)
                existingOldValue.removeObserver(self, forKeyPath: #keyPath(User.pushToken), context: &mainViewContext)
            }
            currentUser?.addObserver(self, forKeyPath: #keyPath(User.pushToken), options: [.new, .old, .initial], context: &mainViewContext)
            currentUser?.addObserver(self, forKeyPath: #keyPath(User.pushChannels), options: [.new, .old, .initial], context: &mainViewContext)
        }
    }
    
    // Deinit
    
    deinit {
        self.currentUser = nil
    }
    
    
    // KVO
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &mainViewContext {
            guard let existingKeyPath = keyPath else {
                return
            }
            switch existingKeyPath {
            case #keyPath(User.pushChannels):
                updatePushChannelsButton()
            case #keyPath(User.pushToken):
                updatePushTokenLabel()
            default:
                fatalError("what wrong in KVO?")
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    

}