//
//  ViewController.swift
//  Memory Management
//
//  Created by Kishor Pahalwani on 18/09/19.
//  Copyright © 2019 Kishor Pahalwani. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
       
    }
    
    @IBAction func ActionToMemoryManagement(_ sender: Any) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MMViewController") as? MMViewController
        
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}


