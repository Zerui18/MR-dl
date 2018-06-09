import UIKit

class NVActivityIndicatorAnimationBallClipRotateMultiple: NVActivityIndicatorAnimationDelegate {

    func setUpAnimation(in layer: CALayer, size: CGSize, color: UIColor) {
        let bigCircleSize: CGFloat = size.width
        let smallCircleSize: CGFloat = size.width / 2
        let longDuration: CFTimeInterval = 1
        let timingFunction = CAMediaTimingFunction(name: convertToCAMediaTimingFunctionName(convertFromCAMediaTimingFunctionName(CAMediaTimingFunctionName.easeInEaseOut)))

        configure(circle: ringTwoHalfHorizontal(size: CGSize(width: bigCircleSize, height: bigCircleSize), color: color),
                 duration: longDuration,
                 timingFunction: timingFunction,
                 layer: layer,
                 reverse: false)
        configure(circle: ringTwoHalfVertical(size: CGSize(width: smallCircleSize, height: smallCircleSize), color: color),
                 duration: longDuration,
                 timingFunction: timingFunction,
                 layer: layer,
                 reverse: true)
    }

    func createAnimationIn(duration: CFTimeInterval, timingFunction: CAMediaTimingFunction, reverse: Bool) -> CAAnimation {
        // Scale animation
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")

        scaleAnimation.keyTimes = [0, 0.5, 1]
        scaleAnimation.timingFunctions = [timingFunction, timingFunction]
        scaleAnimation.values = [1, 0.6, 1]
        scaleAnimation.duration = duration

        // Rotate animation
        let rotateAnimation = CAKeyframeAnimation(keyPath: "transform.rotation.z")

        rotateAnimation.keyTimes = scaleAnimation.keyTimes
        rotateAnimation.timingFunctions = [timingFunction, timingFunction]
        if !reverse {
            rotateAnimation.values = [0, Double.pi, 2 * Double.pi]
        } else {
            rotateAnimation.values = [0, -Double.pi, -2 * Double.pi]
        }
        rotateAnimation.duration = duration

        // Animation
        let animation = CAAnimationGroup()

        animation.animations = [scaleAnimation, rotateAnimation]
        animation.duration = duration
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false

        return animation
    }

    func configure(circle: CALayer, duration: CFTimeInterval, timingFunction: CAMediaTimingFunction, layer: CALayer, reverse: Bool) {
        
        let origin = CGPoint(x: (layer.bounds.size.width - circle.bounds.size.width) / 2,
                           y: (layer.bounds.size.height - circle.bounds.size.width) / 2)
        let animation = createAnimationIn(duration: duration, timingFunction: timingFunction, reverse: reverse)

        circle.frame.origin = origin
        circle.add(animation, forKey: "animation")
        layer.addSublayer(circle)
    }
}

func ringTwoHalfVertical(size: CGSize, color: UIColor)-> CALayer {
    let layer: CAShapeLayer = CAShapeLayer()
    let path: UIBezierPath = UIBezierPath()
    let lineWidth: CGFloat = 2
    
    path.addArc(withCenter: CGPoint(x: size.width / 2, y: size.height / 2),
                radius: size.width / 2,
                startAngle: CGFloat(-3 * Double.pi / 4),
                endAngle: CGFloat(-Double.pi / 4),
                clockwise: true)
    path.move(
        to: CGPoint(x: size.width / 2 - size.width / 2 * cos(CGFloat(Double.pi / 4)),
                    y: size.height / 2 + size.height / 2 * sin(CGFloat(Double.pi / 4)))
    )
    path.addArc(withCenter: CGPoint(x: size.width / 2, y: size.height / 2),
                radius: size.width / 2,
                startAngle: CGFloat(-5 * Double.pi / 4),
                endAngle: CGFloat(-7 * Double.pi / 4),
                clockwise: false)
    layer.fillColor = nil
    layer.strokeColor = color.cgColor
    layer.lineWidth = lineWidth
    
    layer.backgroundColor = nil
    layer.path = path.cgPath
    layer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    return layer
}

func ringTwoHalfHorizontal(size: CGSize, color: UIColor)-> CALayer {
    let layer: CAShapeLayer = CAShapeLayer()
    let path: UIBezierPath = UIBezierPath()
    let lineWidth: CGFloat = 2
    
    path.addArc(withCenter: CGPoint(x: size.width / 2, y: size.height / 2),
                radius: size.width / 2,
                startAngle: CGFloat(3 * Double.pi / 4),
                endAngle: CGFloat(5 * Double.pi / 4),
                clockwise: true)
    path.move(
        to: CGPoint(x: size.width / 2 + size.width / 2 * cos(CGFloat(Double.pi / 4)),
                    y: size.height / 2 - size.height / 2 * sin(CGFloat(Double.pi / 4)))
    )
    path.addArc(withCenter: CGPoint(x: size.width / 2, y: size.height / 2),
                radius: size.width / 2,
                startAngle: CGFloat(-Double.pi / 4),
                endAngle: CGFloat(Double.pi / 4),
                clockwise: true)
    layer.fillColor = nil
    layer.strokeColor = color.cgColor
    layer.lineWidth = lineWidth

    layer.backgroundColor = nil
    layer.path = path.cgPath
    layer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    return layer
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToCAMediaTimingFunctionName(_ input: String) -> CAMediaTimingFunctionName {
	return CAMediaTimingFunctionName(rawValue: input)
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromCAMediaTimingFunctionName(_ input: CAMediaTimingFunctionName) -> String {
	return input.rawValue
}
