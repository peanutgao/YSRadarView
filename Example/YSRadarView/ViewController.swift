//
//  ViewController.swift
//  YSRadarView
//
//  Created by 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 on 01/17/2024.
//  Copyright (c) 2024 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. All rights reserved.
//

import UIKit
import YSRadarView

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let scanRadar = YSRadarView(scanWithRadius: 100, angle: 90, radarLineNum: 4, hollowRadius: 20)
        scanRadar.startColor = .red
        scanRadar.endColor = .clear
        scanRadar.angle = 360
        scanRadar.radarLineNum = 0
        scanRadar.show(targetView: self.view)
        scanRadar.startAnimation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
