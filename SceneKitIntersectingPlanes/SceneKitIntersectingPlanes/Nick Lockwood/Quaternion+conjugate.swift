//
//  Quaternion+conjugate.swift
//  SceneKitIntersectingPlanes
//
//  Created by Bob Wakefield on 9/10/18.
//  Copyright © 2018 Copper Mobile. All rights reserved.
//

import Foundation

extension Quaternion {
    var conjugate: Quaternion {
        return Quaternion(-x, -y, -z, w)
    }
}
