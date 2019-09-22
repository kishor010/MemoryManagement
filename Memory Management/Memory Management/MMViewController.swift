//
//  MMViewController.swift
//  Memory Management
//
//  Created by Kishor Pahalwani on 18/09/19.
//  Copyright © 2019 Kishor Pahalwani. All rights reserved.
//

import UIKit

class MMViewController: UIViewController {

    //let user = User(name: "John")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        runScenario()
        //runScenario()
        // Do any additional setup after loading the view.
    }
    
    func runScenario() {
        let user = User(name: "John")
        let iPhone = Phone(model: "iPhone Xs")
        
        //user.add(phone: iPhone)
        let subscription = CarrierSubscription(
            name: "TelBel",
            countryCode: "0032",
            number: "31415926",
            user: user)
        iPhone.provision(carrierSubscription: subscription)
        print(subscription.completePhoneNumber())
        
        let greetingMaker: () -> String
        
        do {
            let mermaid = CheckFail(who: "caffeinated mermaid")
            greetingMaker = mermaid.greetingMaker
        }
        
        print(greetingMaker()) // TRAP!
    }
}

