//
//  SCNVector3+directions.swift
//  ARKitIntersectingPlanes
//
//  Created by Bob Wakefield on 8/13/18.
//  Copyright © 2018 Copper Mobile. All rights reserved.
//

import SceneKit

extension SCNVector3 {
    static var forward: SCNVector3 { return SCNVector3(x: 0, y: 0, z: 1) }
    static var backward: SCNVector3 { return SCNVector3(x: 0, y: 0, z: -1) }
    static var up: SCNVector3 { return SCNVector3(x: 0, y: 1, z: 0) }
    static var down: SCNVector3 { return SCNVector3(x: 0, y: -1, z: 0) }
    static var left: SCNVector3 { return SCNVector3(x: -1, y: 0, z: 0) }
    static var right: SCNVector3 { return SCNVector3(x: 1, y: 0, z: 0) }
}
