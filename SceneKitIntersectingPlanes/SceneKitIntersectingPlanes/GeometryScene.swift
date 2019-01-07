//
//  GeometryScene.swift
//  SceneKitIntersectingPlanes
//
//  Created by Bob Wakefield on 8/8/18.
//  Copyright © 2018 Copper Mobile. All rights reserved.
//

import SceneKit

// swiftlint:disable identifier_name file_length type_body_length

class GeometryScene: SCNScene {
    struct LineSegment {
        let p0: Vector3
        let p1: Vector3

        var direction: Vector3 {
            return (p1 - p0).normalized()
        }

        init(p0: Vector3, p1: Vector3) {
            self.p0 = p0
            self.p1 = p1
        }

        init(p0: Vector3, v: Vector3) {
            self.p0 = p0
            p1 = p0 + v
        }
    }

    var baseNode: SCNNode?

    var source1: SCNNode?
    var source2: SCNNode?

    override init() {
        super.init()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    class Bullet: SCNNode {
        init(position: SCNVector3, color: UIColor? = .red) {
            super.init()

            let geometry = SCNSphere(radius: 0.02)
            geometry.firstMaterial?.diffuse.contents = color
            self.geometry = geometry

            self.position = position
        }

        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    func normalRotation(plane: SCNNode) -> SCNQuaternion {
        assert(plane.geometry is SCNPlane)

        let orientation = Quaternion(plane.presentation.orientation)

        let direction: Quaternion =
            (orientation * Quaternion(x: 0, y: 0, z: 1, w: 0)) * orientation.conjugate

        return SCNQuaternion(direction)
    }

    func normalVector(plane: SCNNode) -> SCNVector3 {
        let direction = normalRotation(plane: plane)

        let normal = Vector3(direction.x, direction.y, direction.z)

        return SCNVector3(normal)
    }

    func fire1() {
        guard let source = source1 else { return }

        fire(plane: source)
    }

    func fire2() {
        guard let source = source2 else { return }

        fire(plane: source)
    }

    func fire(plane: SCNNode) {
        assert(plane.geometry is SCNPlane)

        let direction: SCNQuaternion = normalRotation(plane: plane)

        let presentationPosition = plane.presentation.position
        let solidColor = (plane.geometry?.firstMaterial?.diffuse.contents as? UIColor)?.withAlphaComponent(1.0)
        let bullet =
            Bullet(
                position:
                SCNVector3(
                    x: presentationPosition.x,
                    y: presentationPosition.y,
                    z: presentationPosition.z
                ),
                color: solidColor
            )

        let force = SCNVector3(x: direction.x * 10, y: direction.y * 10, z: direction.z * 10)
        bullet.physicsBody = SCNPhysicsBody.dynamic()
        bullet.physicsBody?.applyForce(force, asImpulse: true)

        baseNode?.addChildNode(bullet)
    }

    func addPlane(position: SCNVector3, size: CGSize, color: UIColor) -> SCNNode {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0

        color.getRed(&red, green: &green, blue: &blue, alpha: nil)

        let transparentColor = UIColor(red: red, green: green, blue: blue, alpha: 0.4)

        let planeGeometry = SCNPlane(width: size.width, height: size.height)
        let material = SCNMaterial()
        material.diffuse.contents = transparentColor
        material.isDoubleSided = true
        planeGeometry.firstMaterial = material

        let node = SCNNode(geometry: planeGeometry)

        node.position = position
        baseNode?.addChildNode(node)

        return node
    }

    func twoPlanes(baseNode: SCNNode) {
        self.baseNode = baseNode

        let planeGreen = addPlane(position: SCNVector3(0, 0.2, 0), size: CGSize(width: 1.0, height: 1.0), color: .green)
        planeGreen.name = "green"
        let planeBlue = addPlane(position: SCNVector3(0.125, 0.05, 0.1), size: CGSize(width: 0.4, height: 0.3), color: .blue)
        planeBlue.name = "blue"

        // at this point the planes are parallel; they do not intersect
        assert(nil == intersection(plane1: planeGreen, plane2: planeBlue))

        planeGreen.rotation = SCNVector4(0.0, 1.0, 0.0, -Double.pi / 4)
        planeBlue.rotation = SCNVector4(1.0, 0, 0, Double.pi / 8)

        decorate(planeNode: planeGreen)
        decorate(planeNode: planeBlue)

        arbitrarySphere(parentNode: rootNode, position: SCNVector3(0, 0, 0), color: .white, radius: 0.008, tag: "origin")

        if let intersection = intersect3D_2Planes(plane1: planeGreen, plane2: planeBlue) {
//            let lineNode = SCNNode().displayLineSegment(from: SCNVector3(intersection.p0), to: SCNVector3(intersection.p1), withRadius: 0.002, in: .red)
//
//            baseNode?.addChildNode(lineNode)

            if let segment = findIntersectionEndPoints(segment: (point: intersection.p0, normal: intersection.direction), plane1: planeGreen, plane2: planeBlue) {
                let lineNode = SCNNode().displayLineSegment(from: SCNVector3(segment.p0), to: SCNVector3(segment.p1), withRadius: 0.002, in: .red)

                self.baseNode?.addChildNode(lineNode)
            }
        }

        source1 = planeGreen
        source2 = planeBlue
    }

    func decorate(planeNode: SCNNode) {
        arbitrarySphere(position: planeNode.position, color: .black, tag: "plane \(planeNode.name ?? "") position")

        let v1 = planeNode.convertPosition(planeNode.v1, to: baseNode)
        arbitrarySphere(position: v1, color: .white, tag: "plane \(planeNode.name ?? "") v1")
        let v2 = planeNode.convertPosition(planeNode.v2, to: baseNode)
        arbitrarySphere(position: v2, tag: "plane \(planeNode.name ?? "") v2")
        let v3 = planeNode.convertPosition(planeNode.v3, to: baseNode)
        arbitrarySphere(position: v3, tag: "plane \(planeNode.name ?? "") v3")
        let v4 = planeNode.convertPosition(planeNode.v4, to: baseNode)
        arbitrarySphere(position: v4, tag: "plane \(planeNode.name ?? "") v4")

        let side1Node = SCNNode().displayLineSegment(from: v1, to: v3, withRadius: 0.002, in: .orange)
        baseNode?.addChildNode(side1Node)
        let side2Node = SCNNode().displayLineSegment(from: v4, to: v2, withRadius: 0.002, in: .white)
        baseNode?.addChildNode(side2Node)
        let side3Node = SCNNode().displayLineSegment(from: v2, to: v3, withRadius: 0.002, in: .yellow)
        baseNode?.addChildNode(side3Node)
        let side4Node = SCNNode().displayLineSegment(from: v1, to: v4, withRadius: 0.002, in: .blue)
        baseNode?.addChildNode(side4Node)
    }

    func arbitrarySphere(parentNode: SCNNode? = nil, position: SCNVector3, color: UIColor = .red, radius: CGFloat = 0.008, tag: String = "\(#function) \(#line)") {
        let parentNode = parentNode ?? baseNode

        let sphere = SCNSphere(radius: radius)
        sphere.firstMaterial?.diffuse.contents = color
        sphere.firstMaterial?.isDoubleSided = true
        let sphereNode = SCNNode(geometry: sphere)

        sphereNode.position = position
        parentNode?.addChildNode(sphereNode)

        print("sphere: \(position.x),\(position.y),\(position.z) \(tag)")
    }

    func arbitrarySphere(position: Vector3, color: UIColor = .red, radius: CGFloat = 0.008, tag: String = "\(#function) \(#line)") {
        arbitrarySphere(position: SCNVector3(position), color: color, radius: radius, tag: tag)
    }

    func intersection(plane1: SCNNode, plane2: SCNNode) -> LineSegment? {
        // Intersection of 2-planes: a variation based on the 3-plane version.
        // see: Graphics Gems 1 pg 305
        //
        // Note that the 'normal' components of the planes need not be unit length

        // logically the 3rd plane, but we only use the normal component.
        let p1Normal = Vector3(plane1.worldFront)
        let p2Normal = Vector3(plane2.worldFront)
        let p3Normal = p1Normal.cross(p2Normal)

        let determinant = p3Normal.lengthSquared

        // If the determinant is 0, that means parallel planes, no intersection.
        // note: you may want to check against an epsilon value here.
        guard !(0 ~= determinant) else { return nil }

        let v1 = plane1.convertPosition(plane1.v1, to: baseNode)
        let v2 = plane2.convertPosition(plane2.v2, to: baseNode)

        let d1 = -(p1Normal.x * v1.x + p1Normal.y * v1.y + p1Normal.z * v1.z)
        let d2 = -(p2Normal.x * v2.x + p2Normal.y * v2.y + p2Normal.z * v2.z)

        let point = (p3Normal.cross(p2Normal) * d1 + p1Normal.cross(p3Normal) * d2) / determinant
        let normal = p3Normal.normalized()

        return findIntersectionEndPoints(segment: (point: point, normal: normal), plane1: plane1, plane2: plane2)
    }

    // **** Intersection found. Now to find its end points ****

    func findIntersectionEndPoints(segment: (point: Vector3, normal: Vector3), plane1: SCNNode, plane2: SCNNode) -> LineSegment? {
        let segment1 = intersectionsWithEdges(segment: (segment.point, segment.normal), plane: plane1)
        let segment2 = intersectionsWithEdges(segment: (segment.point, segment.normal), plane: plane2)

        var intersectionLength1: Float = 0
        var intersectionLength2: Float = 0

        if let segment = segment1 {
            intersectionLength1 = abs((segment.p1 - segment.p0).lengthSquared)

            arbitrarySphere(position: SCNVector3(segment.p0), color: .green, tag: "plane 1 intersection p0")
            arbitrarySphere(position: SCNVector3(segment.p1), color: .green, tag: "plane 1 intersection p1")
        }

        if let segment = segment2 {
            intersectionLength2 = abs((segment.p1 - segment.p0).lengthSquared)

            arbitrarySphere(position: SCNVector3(segment.p0), color: .blue, tag: "plane 2 intersection p0")
            arbitrarySphere(position: SCNVector3(segment.p1), color: .blue, tag: "plane 2 intersection p1")
        }

        return intersectionLength1 < intersectionLength2 ? segment1 : segment2
    }

    func intersectionsWithEdges(segment: (point: Vector3, length: Vector3), plane: SCNNode) -> LineSegment? {
        let diagonalLength = abs((Vector3(plane.v3) - Vector3(plane.v1)).length)

        let p0 = segment.point + segment.length * diagonalLength
        let p1 = segment.point - segment.length * diagonalLength

        guard let intersection0 = intersectionWithEdge(line: LineSegment(p0: segment.point, p1: p0), plane: plane)
        else { return nil }
        guard let intersection1 = intersectionWithEdge(line: LineSegment(p0: segment.point, p1: p1), plane: plane)
        else { return nil }

        return LineSegment(p0: intersection0, p1: intersection1)
    }

    // convert this 3D issue to a 2D issue.
    //
    func intersectionWithEdge(line segment: LineSegment, plane: SCNNode) -> Vector3? {
        assert(plane.geometry is SCNPlane)

        guard let baseNode = self.baseNode else { return nil }

        let p0 = Vector3(baseNode.convertPosition(SCNVector3(segment.p0), to: plane))
        let p1 = Vector3(baseNode.convertPosition(SCNVector3(segment.p1), to: plane))

        guard 0.0 ~= p0.z && 0.0 ~= p1.z else { return nil }

        let v1 = Vector3(plane.v1)
        let v2 = Vector3(plane.v2)
        let v3 = Vector3(plane.v3)
        let v4 = Vector3(plane.v4)

        var intersection: LineIntersection = intersect2D_2Segments(segment1: LineSegment(p0: p0, p1: p1), segment2: LineSegment(p0: v1, p1: v3))
        if let point = intersection.point {
            return Vector3(plane.convertPosition(SCNVector3(point), to: baseNode))
        }

        intersection = intersect2D_2Segments(segment1: LineSegment(p0: p0, p1: p1), segment2: LineSegment(p0: v1, p1: v4))
        if let point = intersection.point {
            return Vector3(plane.convertPosition(SCNVector3(point), to: baseNode))
        }

        intersection = intersect2D_2Segments(segment1: LineSegment(p0: p0, p1: p1), segment2: LineSegment(p0: v2, p1: v3))
        if let point = intersection.point {
            return Vector3(plane.convertPosition(SCNVector3(point), to: baseNode))
        }

        intersection = intersect2D_2Segments(segment1: LineSegment(p0: p0, p1: p1), segment2: LineSegment(p0: v2, p1: v4))
        if let point = intersection.point {
            return Vector3(plane.convertPosition(SCNVector3(point), to: baseNode))
        }

        return nil
    }

    func lineSegmentsIntersection(a: LineSegment, b: LineSegment) -> Vector3? {
        let a1 = a.p1
        let a0 = a.p0

        let b1 = b.p1
        let b0 = b.p0

        let da = (a1 - a0).normalized()
        let db = (b1 - b0).normalized()
        let dc = (b0 - a0).normalized()

        guard 0 == dc.dot(dc.cross(db)) else { return nil }

        let s = (dc.cross(db).dot(da.cross(db))) / da.cross(db).lengthSquared

        guard s >= 0.0 && s <= 1.0 else { return nil }

        return a0 + da * Vector3(s, s, s)
    }

    enum LineIntersection {
        case disjoint
        case intersect(point: Vector3)
        case overlap(p0: Vector3, p1: Vector3)

        var point: Vector3? {
            switch self {
            case .disjoint: return nil
            case let .intersect(point): return point
            case .overlap: return nil
            }
        }

        var segment: LineSegment? {
            switch self {
            case .disjoint: return nil
            case .intersect: return nil
            case let .overlap(p0, p1): return LineSegment(p0: p0, p1: p1)
            }
        }
    }

    // adapted from: http://geomalgorithms.com/a05-_intersect-1.html
    // intersect3D_2Planes(): find the 3D intersection of two planes
    //    Input:  two planes plane1 and plane2
    //    Output: *L = the intersection line (when it exists)
    //    Return: 0 = disjoint (no intersection)
    //            1 = the two  planes coincide
    //            2 =  intersection in the unique line *L
    func intersect3D_2Planes(plane1: SCNNode, plane2: SCNNode) -> LineSegment? {
        assert(plane1.geometry is SCNPlane && plane2.geometry is SCNPlane)

        let normal1 = Vector3(plane1.worldFront)
        let normal2 = Vector3(plane2.worldFront)

        let p1v1 = Vector3(plane1.convertPosition(plane1.v1, to: baseNode))
        let p2v1 = Vector3(plane2.convertPosition(plane2.v1, to: baseNode))

        let u = normal1.cross(normal2) // cross product
        let ax: Scalar = (u.x >= 0 ? u.x : -u.x)
        let ay: Scalar = (u.y >= 0 ? u.y : -u.y)
        let az: Scalar = (u.z >= 0 ? u.z : -u.z)

        // test if the two planes are parallel
        if (ax + ay + az) ~= 0.0 { // Pn1 and Pn2 are near parallel
            // test if disjoint or coincide
            let v = p2v1 - p1v1
            if normal1.dot(v) == 0 { // Pn2.V0 lies in Pn1
                return nil // Pn1 and Pn2 coincide
            } else {
                return nil
            } // plane1 and plane2 are disjoint
        }

        // Pn1 and Pn2 intersect in a line
        // first determine max abs coordinate of cross product
        var maxc = 0 // max coordinate
        if ax > ay {
            maxc = ax > az ? 1 : 3

        } else {
            maxc = ay > az ? 2 : 3
        }

        // next, to get a point on the intersect line
        // zero the max coord, and solve for the other two
        var iP = Vector3.zero // intersect point
        let d1 = -normal1.dot(p1v1) // note: could be pre-stored  with plane
        let d2 = -normal2.dot(p2v1) // ditto

        switch maxc { // select max coordinate
        case 1: // intersect with x=0
            iP.x = 0
            iP.y = (d2 * normal1.z - d1 * normal2.z) / u.x
            iP.z = (d1 * normal2.y - d2 * normal1.y) / u.x
        case 2: // intersect with y=0
            iP.x = (d1 * normal2.z - d2 * normal1.z) / u.y
            iP.y = 0
            iP.z = (d2 * normal1.x - d1 * normal2.x) / u.y
        case 3: // intersect with z=0
            iP.x = (d2 * normal1.y - d1 * normal2.y) / u.z
            iP.y = (d1 * normal2.x - d2 * normal1.x) / u.z
            iP.z = 0
        default:
            assert(false, "don't know how we got here!")
        }

        arbitrarySphere(position: iP, color: .magenta, tag: "point of intersection")

        return LineSegment(p0: iP, p1: iP + u)
    }

    let SMALLNUM: Scalar = 0.00000001

    private func dot(_ u: Vector3, _ v: Vector3) -> Scalar {
        return u.x * v.x + u.y * v.y + u.z + v.z
    }

    private func perp(_ u: Vector3, _ v: Vector3) -> Scalar {
        return u.x * v.y - u.y * v.x
    }

    // inSegment(): determine if a point is inside a segment
    //    Input:  a point P, and a collinear segment S
    //    Return: 1 = P is inside S
    //            0 = P is  not inside S
    func inSegment(_ point: Vector3, _ segment: LineSegment) -> Bool {
        if segment.p0.x != segment.p1.x { // S is not  vertical
            if segment.p0.x <= point.x && point.x <= segment.p1.x {
                return true
            }
            if segment.p0.x >= point.x && point.x >= segment.p1.x {
                return true
            }
        } else { // S is vertical, so test y  coordinate
            if segment.p0.y <= point.y && point.y <= segment.p1.y {
                return true
            }
            if segment.p0.y >= point.y && point.y >= segment.p1.y {
                return true
            }
        }
        return false
    }

    // adapted from: http://geomalgorithms.com/a05-_intersect-1.html
    // intersect2D_2Segments(): find the 2D intersection of 2 finite segments
    //    Input:  two finite segments S1 and S2
    //    Output: *I0 = intersect point (when it exists)
    //            *I1 =  endpoint of intersect segment [I0,I1] (when it exists)
    //    Return: 0=disjoint (no intersect)
    //            1=intersect  in unique point I0
    //            2=overlap  in segment from I0 to I1

    func intersect2D_2Segments(segment1: LineSegment, segment2: LineSegment) -> LineIntersection {
        let u: Vector3 = segment1.p1 - segment1.p0
        let v: Vector3 = segment2.p1 - segment2.p0
        let w: Vector3 = segment1.p0 - segment2.p0
        let d = perp(u, v)

        // test if  they are parallel (includes either being a point)
        if abs(d) < SMALLNUM { // S1 and S2 are parallel
            if perp(u, w) != 0 || perp(v, w) != 0 {
                return .disjoint // they are NOT collinear
            }
            // they are collinear or degenerate
            // check if they are degenerate  points
            let du = dot(u, u)
            let dv = dot(v, v)
            if du == 0 && dv == 0 { // both segments are points
                if segment1.p0 != segment2.p0 { // they are distinct  points
                    return .disjoint
                }
                return .intersect(point: segment1.p0)
            }
            if du == 0 { // S1 is a single point
                if !inSegment(segment1.p0, segment2) { // but is not in S2
                    return .disjoint
                }
                return .intersect(point: segment1.p0)
            }
            if dv == 0 { // S2 a single point
                if !inSegment(segment2.p0, segment1) { // but is not in S1
                    return .disjoint
                }
                return .intersect(point: segment2.p0)
            }
            // they are collinear segments - get  overlap (or not)
            var t0: Scalar = 0
            var t1: Scalar = 0 // endpoints of S1 in eqn for S2
            let w2 = segment1.p1 - segment2.p0
            if v.x != 0 {
                t0 = w.x / v.x
                t1 = w2.x / v.x
            } else {
                t0 = w.y / v.y
                t1 = w2.y / v.y
            }
            if t0 > t1 { // must have t0 smaller than t1
                let temp = t0
                t0 = t1
                t1 = temp // swap if not
            }
            if t0 > 1 || t1 < 0 {
                return .disjoint // NO overlap
            }
            t0 = t0 < 0 ? 0 : t0 // clip to min 0
            t1 = t1 > 1 ? 1 : t1 // clip to max 1
            if t0 == t1 { // intersect is a point
                return .intersect(point: segment2.p0 + v * t0)
            }

            // they overlap in a valid subsegment
            return .overlap(p0: segment2.p0 + v * t0, p1: segment2.p0 + v * t1)
        }

        // the segments are skew and may intersect in a point
        // get the intersect parameter for S1
        let sI = perp(v, w) / d
        if sI < 0 || sI > 1 { // no intersect with S1
            return .disjoint
        }

        // get the intersect parameter for S2
        let tI = perp(u, w) / d
        if tI < 0 || tI > 1 { // no intersect with S2
            return .disjoint
        }

        return .intersect(point: segment1.p0 + u * sI)
    }
}

extension SCNNode {
    var v1: SCNVector3 {
        assert(geometry is SCNPlane)

        return boundingBox.min
    }

    var v2: SCNVector3 {
        assert(geometry is SCNPlane)

        return boundingBox.max
    }

    var v3: SCNVector3 {
        assert(geometry is SCNPlane)

        let (min, max) = boundingBox

        return SCNVector3(min.x, max.y, min.z)
    }

    var v4: SCNVector3 {
        assert(geometry is SCNPlane)

        let (min, max) = boundingBox

        return SCNVector3(max.x, min.y, max.z)
    }
}

func normalizeVector(_ iv: SCNVector3) -> SCNVector3 {
    let length = sqrt(iv.x * iv.x + iv.y * iv.y + iv.z * iv.z)
    if length == 0 {
        return SCNVector3(0.0, 0.0, 0.0)
    }

    return SCNVector3(iv.x / length, iv.y / length, iv.z / length)
}

extension SCNNode {
    func displayLineSegment(
        from startPoint: SCNVector3,
        to endPoint: SCNVector3,
        withRadius: CGFloat,
        in color: UIColor
    ) -> SCNNode {
        let w = SCNVector3(x: endPoint.x - startPoint.x,
                           y: endPoint.y - startPoint.y,
                           z: endPoint.z - startPoint.z)
        let l = CGFloat(sqrt(w.x * w.x + w.y * w.y + w.z * w.z))

        if l == 0.0 {
            // two points together.
            let sphere = SCNSphere(radius: withRadius)
            sphere.firstMaterial?.diffuse.contents = color
            geometry = sphere
            position = startPoint
            return self
        }

        let cyl = SCNCylinder(radius: withRadius, height: l)
        cyl.firstMaterial?.diffuse.contents = color

        geometry = cyl

        // original vector of cylinder above 0,0,0
        let ov = SCNVector3(0, l / 2.0, 0)
        //target vector, in new coordination
        let nv = SCNVector3((endPoint.x - startPoint.x) / 2.0, (endPoint.y - startPoint.y) / 2.0,
                            (endPoint.z - startPoint.z) / 2.0)

        // axis between two vector
        let av = SCNVector3((ov.x + nv.x) / 2.0, (ov.y + nv.y) / 2.0, (ov.z + nv.z) / 2.0)

        // normalized axis vector
        let av_normalized = normalizeVector(av)
        let q0 = Float(0.0) // cos(angel/2), angle is always 180 or M_PI
        let q1 = Float(av_normalized.x) // x' * sin(angle/2)
        let q2 = Float(av_normalized.y) // y' * sin(angle/2)
        let q3 = Float(av_normalized.z) // z' * sin(angle/2)

        let r_m11 = q0 * q0 + q1 * q1 - q2 * q2 - q3 * q3
        let r_m12 = 2 * q1 * q2 + 2 * q0 * q3
        let r_m13 = 2 * q1 * q3 - 2 * q0 * q2
        let r_m21 = 2 * q1 * q2 - 2 * q0 * q3
        let r_m22 = q0 * q0 - q1 * q1 + q2 * q2 - q3 * q3
        let r_m23 = 2 * q2 * q3 + 2 * q0 * q1
        let r_m31 = 2 * q1 * q3 + 2 * q0 * q2
        let r_m32 = 2 * q2 * q3 - 2 * q0 * q1
        let r_m33 = q0 * q0 - q1 * q1 - q2 * q2 + q3 * q3

        transform.m11 = r_m11
        transform.m12 = r_m12
        transform.m13 = r_m13
        transform.m14 = 0.0

        transform.m21 = r_m21
        transform.m22 = r_m22
        transform.m23 = r_m23
        transform.m24 = 0.0

        transform.m31 = r_m31
        transform.m32 = r_m32
        transform.m33 = r_m33
        transform.m34 = 0.0

        transform.m41 = (startPoint.x + endPoint.x) / 2.0
        transform.m42 = (startPoint.y + endPoint.y) / 2.0
        transform.m43 = (startPoint.z + endPoint.z) / 2.0
        transform.m44 = 1.0
        return self
    }
}
