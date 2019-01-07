//
//  VectorMath+directions.swift
//  SceneKitIntersectingPlanes
//
//  Created by Bob Wakefield on 8/13/18.
//  Copyright © 2018 Copper Mobile. All rights reserved.
//

import Foundation

extension Vector3 {
    static var forward: Vector3 { return Vector3(x: 0, y: 0, z: 1) }
    static var backward: Vector3 { return Vector3(x: 0, y: 0, z: -1) }
    static var up: Vector3 { return Vector3(x: 0, y: 1, z: 0) }
    static var down: Vector3 { return Vector3(x: 0, y: -1, z: 0) }
    static var left: Vector3 { return Vector3(x: -1, y: 0, z: 0) }
    static var right: Vector3 { return Vector3(x: 1, y: 0, z: 0) }
}
