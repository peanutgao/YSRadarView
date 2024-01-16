//
// *************************************************
// Created by Joseph Koh on 2024/1/17.
// Author: Joseph Koh
// Email: Joseph0750@gmail.com
// Create Time: 2024/1/17 01:06
// *************************************************
//

import UIKit

// MARK: - YSRadarView

public class YSRadarView: UIView {
    public enum RadarViewType {
        case scan
        case diffuse
    }

    public var radarLineColor: UIColor?
    public var startColor: UIColor?
    public var endColor: UIColor?

    public var sectorRadius: CGFloat = 0
    public var angle = 0
    public var radarLineNum = 0
    public var hollowRadius = 0

    public var startRadius: CGFloat = 0
    public var endRadius: CGFloat = 0
    public var circleColor: UIColor?

    public var timer: Timer?
    public var radarViewType: RadarViewType = .scan

    public init(scanWithRadius radius: CGFloat, angle: Int, radarLineNum: Int, hollowRadius: CGFloat) {
        super.init(frame: CGRect(x: 0, y: 0, width: radius * 2, height: radius * 2))
        self.radarViewType = .scan
        self.sectorRadius = radius
        self.angle = angle
        self.radarLineNum = radarLineNum - 1
        self.hollowRadius = Int(hollowRadius)
        self.backgroundColor = UIColor.clear
    }

    public init(diffuseWithStartRadius startRadius: CGFloat, endRadius: CGFloat, circleColor: UIColor) {
        super.init(frame: CGRect(x: 0, y: 0, width: endRadius * 2, height: endRadius * 2))
        self.radarViewType = .diffuse
        self.startRadius = startRadius
        self.endRadius = endRadius
        self.circleColor = circleColor
        self.backgroundColor = UIColor.clear
    }

    public func show(targetView: UIView) {
        center = targetView.center
        targetView.addSubview(self)
    }

    public func dismiss() {
        removeFromSuperview()
    }

    public func startAnimation() {
        if radarViewType == .scan {
            let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
            rotationAnimation.toValue = NSNumber(value: 1 * .pi * 2.0)
            rotationAnimation.duration = 2
            rotationAnimation.isCumulative = true
            rotationAnimation.repeatCount = .greatestFiniteMagnitude
            layer.add(rotationAnimation, forKey: "rotationAnimation")
        } else {
            diffuseAnimation()
            timer = Timer.scheduledTimer(
                timeInterval: 0.5,
                target: self,
                selector: #selector(diffuseAnimation),
                userInfo: nil,
                repeats: true
            )
        }
    }

    public func stopAnimation() {
        if radarViewType == .scan {
            layer.removeAnimation(forKey: "rotationAnimation")
        } else {
            timer?.invalidate()
            timer = nil
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func draw(_: CGRect) {
        if radarViewType == .scan {
            if startColor == nil {
                startColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
            }
            if endColor == nil {
                endColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
            }
            if radarLineColor == nil {
                radarLineColor = UIColor(white: 1, alpha: 0.7)
            }

            drawRadarLine()

            if let context = UIGraphicsGetCurrentContext() {
                for i in 0 ..< angle {
                    let color = colorWithCurrentAngleProportion(angleProportion: CGFloat(i) / CGFloat(angle))
                    drawSector(context: context, color: color, startAngle: CGFloat(-90 - i))
                }
            }
        }
    }
}

private extension YSRadarView {
    @objc func diffuseAnimation() {
        let imgView = UIImageView()
        if let circleImage = drawCircle() {
            imgView.image = circleImage
            imgView.frame = CGRect(x: 0, y: 0, width: startRadius, height: startRadius)
            imgView.center = CGPoint(x: bounds.width * 0.5, y: bounds.height * 0.5)
            addSubview(imgView)

            UIView.animate(withDuration: 2, delay: 0, options: .curveEaseIn, animations: {
                imgView.frame = CGRect(x: 0, y: 0, width: self.endRadius * 2, height: self.endRadius * 2)
                imgView.center = CGPoint(x: self.bounds.width * 0.5, y: self.bounds.height * 0.5)
                imgView.alpha = 0
            }, completion: { _ in
                imgView.removeFromSuperview()
            })
        }
    }

    func drawCircle() -> UIImage? {
        UIGraphicsBeginImageContext(CGSize(width: endRadius * 2, height: endRadius * 2))
        if let context = UIGraphicsGetCurrentContext() {
            context.move(to: CGPoint(x: bounds.width * 0.5, y: bounds.height * 0.5))
            context.setFillColor(circleColor?.cgColor ?? UIColor.clear.cgColor)
            context.addArc(
                center: CGPoint(x: bounds.width * 0.5, y: bounds.height * 0.5),
                radius: endRadius,
                startAngle: 0,
                endAngle: -2 * .pi,
                clockwise: true
            )
            context.fillPath()
        }
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }

    func drawSector(context: CGContext, color: UIColor, startAngle: CGFloat) {
        context.setFillColor(color.cgColor)
        context.setLineWidth(0)
        context.move(to: CGPoint(x: bounds.width * 0.5, y: bounds.height * 0.5))
        context.addArc(
            center: CGPoint(x: bounds.width * 0.5, y: bounds.height * 0.5),
            radius: sectorRadius,
            startAngle: startAngle * .pi / 180,
            endAngle: (startAngle - 1) * .pi / 180,
            clockwise: true
        )
        context.closePath()
        context.drawPath(using: .fillStroke)
    }

    func drawRadarLine() {
        let minRadius = (sectorRadius - CGFloat(hollowRadius)) * pow(0.618, Double(radarLineNum - 1))

        drawLine(radius: CGFloat(hollowRadius) + minRadius * 0.382)

        for i in 0 ..< radarLineNum {
            drawLine(radius: CGFloat(hollowRadius) + minRadius / pow(0.618, Double(i)))
        }
    }

    func drawLine(radius: CGFloat) {
        let solidLine = CAShapeLayer()
        let solidPath = CGMutablePath()
        solidLine.lineWidth = 1.0
        solidLine.strokeColor = radarLineColor?.cgColor
        solidLine.fillColor = UIColor.clear.cgColor
        solidPath.addEllipse(in: CGRect(
            x: bounds.width * 0.5 - radius,
            y: bounds.height * 0.5 - radius,
            width: radius * 2,
            height: radius * 2
        ))
        solidLine.path = solidPath
        layer.addSublayer(solidLine)
    }
}

extension YSRadarView {
    func colorWithCurrentAngleProportion(angleProportion: CGFloat) -> UIColor {
        guard let startColor, let endColor else {
            return UIColor.black
        }

        var startRed: CGFloat = 0
        var startGreen: CGFloat = 0
        var startBlue: CGFloat = 0
        var startAlpha: CGFloat = 0

        var endRed: CGFloat = 0
        var endGreen: CGFloat = 0
        var endBlue: CGFloat = 0
        var endAlpha: CGFloat = 0

        startColor.getRed(&startRed, green: &startGreen, blue: &startBlue, alpha: &startAlpha)
        endColor.getRed(&endRed, green: &endGreen, blue: &endBlue, alpha: &endAlpha)

        let currentRed = startRed + (endRed - startRed) * angleProportion
        let currentGreen = startGreen + (endGreen - startGreen) * angleProportion
        let currentBlue = startBlue + (endBlue - startBlue) * angleProportion
        let currentAlpha = startAlpha + (endAlpha - startAlpha) * angleProportion

        return UIColor(red: currentRed, green: currentGreen, blue: currentBlue, alpha: currentAlpha)
    }
}
