//
//  ViewController.swift
//  TestAudioRec
//
//  Created by Alexey Govorovsky on 19.05.2020.
//  Copyright © 2020 ITV/Axxonsoft. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let vc = RecordAudioViewController()
        self.navigationController?.pushViewController(vc, animated: false)
    }


}

