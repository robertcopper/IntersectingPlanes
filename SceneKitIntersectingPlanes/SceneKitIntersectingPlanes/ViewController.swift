//
//  ViewController.swift
//  SceneKitIntersectingPlanes
//
//  Created by Bob Wakefield on 8/8/18.
//  Copyright © 2018 Copper Mobile. All rights reserved.
//

import SceneKit
import UIKit

class ViewController: UIViewController {
    @IBOutlet var scnView: SCNView?

    @IBAction func fire1(sender _: UIButton) {
        guard let scene = scnView?.scene as? GeometryScene else { return }

        scene.fire1()
    }

    @IBAction func fire2(sender _: UIButton) {
        guard let scene = scnView?.scene as? GeometryScene else { return }

        scene.fire2()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
        let scene = GeometryScene()
        scnView?.scene = scene
        scnView?.backgroundColor = .black

        let baseNode = SCNNode(geometry: nil)
        baseNode.position = SCNVector3(0.0, 0.0, -1.0)
        scene.rootNode.addChildNode(baseNode)

        scene.twoPlanes(baseNode: baseNode)
    }
}
