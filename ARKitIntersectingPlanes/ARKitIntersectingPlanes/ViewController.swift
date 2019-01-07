//
//  ViewController.swift
//  ARKitIntersectingPlanes
//
//  Created by Bob Wakefield on 8/8/18.
//  Copyright © 2018 Copper Mobile. All rights reserved.
//

import ARKit
import SceneKit
import UIKit

class ViewController: UIViewController {
    @IBOutlet var sceneView: ARSCNView?
    @IBOutlet var trackingStateLabel: UILabel?

    let standardConfiguration: ARWorldTrackingConfiguration = {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.isLightEstimationEnabled = true
        return configuration
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        let scene = GeometryScene()
        sceneView?.scene = scene

        let position = SCNVector3(0.0, 0.0, -1.0)
        let baseNode = SCNNode(geometry: nil)
        baseNode.position = scene.rootNode.convertVector(position, from: baseNode)
        scene.rootNode.addChildNode(baseNode)

        scene.twoPlanes(baseNode: baseNode)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Run the view's session
        runSession()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Pause the view's session
        sceneView?.session.pause()
    }

    func runSession() {
        sceneView?.delegate = self
        sceneView?.session.run(standardConfiguration)
        #if DEBUG
            sceneView?.showsStatistics = true
            sceneView?.debugOptions = [.showFeaturePoints, .showWorldOrigin]
        #endif
    }
}

extension ViewController: ARSCNViewDelegate {
    func session(_: ARSession, didFailWithError _: Error) {
        // Present an error message to the user
    }

    func sessionWasInterrupted(_: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
    }

    func sessionInterruptionEnded(_: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
    }

    func session(_: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {
        case .notAvailable:
            trackingStateLabel?.text = "Tracking not available"
            trackingStateLabel?.textColor = .red
        case .normal:
            trackingStateLabel?.text = "Tracking normal"
            trackingStateLabel?.textColor = .green
        case let .limited(reason):
            switch reason {
            case .initializing:
                trackingStateLabel?.text = "Tracking limited: initializing"
            case .excessiveMotion:
                trackingStateLabel?.text = "Tracking limited: excessive motion"
            case .insufficientFeatures:
                trackingStateLabel?.text = "Tracking limited: insufficient features"
            case .relocalizing:
                trackingStateLabel?.text = "Tracking limited: relocalizing"
            }
            trackingStateLabel?.textColor = .yellow
        }
    }
}
