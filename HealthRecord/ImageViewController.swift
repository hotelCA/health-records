//
//  ViewController.swift
//  HealthRecord
//
//  Created by Quoc Anh Tran on 6/15/17.
//  Copyright © 2017 hotelCA. All rights reserved.
//

import UIKit

protocol ImageViewControllerProtocol {

    func deleteAHealthImage()
}

class ImageViewController: UIViewController {

    @IBOutlet var canvas: UIView!
    @IBOutlet var imageView: UIImageView!
    var healthImage: HealthImage?
    var delegate: ImageViewControllerProtocol!
    var dot: UIView!
    var panGesture: UIPanGestureRecognizer!
    var bezierPath: UIBezierPath!
    
    @IBAction func deletePressed(_ sender: Any) {

        delegate.deleteAHealthImage()
        _ = navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = healthImage?.image

        panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.draggedView(_:)))
//        panGesture.minimumNumberOfTouches = 0

        dot = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 30, height: 30)))
        dot.backgroundColor = .red
        dot.clipsToBounds = true
        dot.layer.cornerRadius = 15
        self.view.addSubview(dot)

        // create CAShapeLayer
        let shapeLayer = CAShapeLayer()
        bezierPath = dialogBezierPathWithFrame(frame: canvas.frame, arrowOrientation: .down)
        shapeLayer.path = bezierPath.cgPath
        shapeLayer.fillColor = UIColor.white.cgColor
        shapeLayer.fillRule = kCAFillRuleEvenOdd
        canvas.layer.mask = shapeLayer

        canvas.isUserInteractionEnabled = true
        canvas.addGestureRecognizer(panGesture)
    }

    func dialogBezierPathWithFrame(frame: CGRect, arrowOrientation orientation: UIImageOrientation, arrowLength: CGFloat = 40.0) -> UIBezierPath {
        // 1. Translate frame to neutral coordinate system & transpose it to fit the orientation.
        var transposedFrame = CGRect.zero
        transposedFrame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)

        // 2. We need 7 points for our Bezier path
        let midX = transposedFrame.midX
        let point1 = CGPoint(x: transposedFrame.minX, y: transposedFrame.minY + arrowLength)
        let point2 = CGPoint(x: midX - (arrowLength / 2), y: transposedFrame.minY + arrowLength)
        let point3 = CGPoint(x: midX, y: transposedFrame.minY)
        let point4 = CGPoint(x: midX + (arrowLength / 2), y: transposedFrame.minY + arrowLength)
        let point5 = CGPoint(x: transposedFrame.maxX, y: transposedFrame.minY + arrowLength)
        let point6 = CGPoint(x: transposedFrame.maxX, y: transposedFrame.maxY)
        let point7 = CGPoint(x: transposedFrame.minX, y: transposedFrame.maxY)

        // 3. Build our Bezier path
        let path = UIBezierPath()
        path.move(to: point1)
        path.addLine(to: point2)
        path.addLine(to: point3)
        path.addLine(to: point4)
        path.addLine(to: point5)
        path.addLine(to: point6)
        path.addLine(to: point7)
        path.close()

        return path
    }

    @objc func draggedView(_ sender: UIPanGestureRecognizer) {

        canvas.bringSubview(toFront: dot)

        var translation = sender.translation(in: canvas)
        var reference = sender.location(in: canvas)
        reference.x += canvas.frame.origin.x
        reference.y += canvas.frame.origin.y
        let diff = CGPoint(x: reference.x - self.dot.center.x, y: reference.y - self.dot.center.y)
        translation.x = diff.x + translation.x
        translation.y = diff.y + translation.y

        print("Translation x: \(translation.x), y: \(translation.y)")
        print("Reference x: \(reference.x), y: \(reference.y)")

//        let point = CGPoint(x: dot.center.x + translation.x, y: dot.center.y + translation.y)
//
//        if canvas.frame.contains(point) {
//
//            self.dot.center = point
//        }

        for i in (1...20).reversed() {
            translation = CGPoint(x: translation.x * CGFloat(i) / 20.0, y: translation.y  * CGFloat(i) / 20.0)
//            let referencePoint = CGPoint(x: reference.x + translation.x, y: reference.y + translation.y)
            let dot = CGPoint(x: self.dot.center.x + translation.x, y: self.dot.center.y + translation.y)
            print(i)

            var point = CGPoint.zero
            point.x = dot.x - canvas.frame.origin.x
            point.y = dot.y - canvas.frame.origin.y

            if bezierPath.contains(point) {

                self.dot.center = dot
                break
            }
//            if !crossBounds(point: referencePoint) {
//
//                self.dot.center = referencePoint
//                print("i: \(i)")
//                break
//
//            } else if !crossBounds(point: dot) && areAllPointsLegal(points: [referencePoint]) {
//
//                self.dot.center = dot
//                print("i: \(i)")
//                break
//            }
        }
        sender.setTranslation(CGPoint.zero, in: canvas)
    }

    private func crossBounds(point: CGPoint) -> Bool {

        let pointA = CGPoint(x: point.x + 20, y: point.y)
        let pointB = CGPoint(x: point.x - 20, y: point.y)
        let pointC = CGPoint(x: point.x, y: point.y + 20)
        let pointD = CGPoint(x: point.x, y: point.y - 20)

        let points = [pointA, pointB, pointC, pointD]

        if areAllPointsLegal(points: points) {

            return false

        } else {

            return true
        }
    }

    private func areAllPointsLegal(points: [CGPoint]) -> Bool {

        for point in points {

//            print(getPixelColorAt(point: point))
            if getPixelColorAt(point: point).cgColor.components![0] != 1 {

//                print(getPixelColorAt(point: point).cgColor.components![0])
                return false
            }
        }

        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        for touch in touches {

            let location = touch.location(in: self.view)
            print("Location x: \(location.x), y: \(location.y)")

            var point = CGPoint.zero
            point.x = location.x - canvas.frame.origin.x
            point.y = location.y - canvas.frame.origin.y

            if bezierPath.contains(point) {

                dot.center.x = location.x
                dot.center.y = location.y
            }
        }
    }

    func getPixelColorAt(point: CGPoint) -> UIColor{

        let pixel = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: 4)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)

        context!.translateBy(x: -point.x, y: -point.y)
        self.view.layer.render(in: context!)
        let color:UIColor = UIColor(red: CGFloat(pixel[0])/255.0,
                                    green: CGFloat(pixel[1])/255.0,
                                    blue: CGFloat(pixel[2])/255.0,
                                    alpha: CGFloat(pixel[3])/255.0)

        pixel.deallocate(capacity: 4)
        return color
    }
}

