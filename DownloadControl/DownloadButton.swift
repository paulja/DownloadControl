// Copyright (c) 2019. Paul Jackson

import UIKit

/// DownloadButton provides UI for the different possible download states, as well as supporting all the UIButton
/// touch events.
final class DownloadButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    // MARK: - Public -

    /// Possible states the control can be in.
    ///
    /// - ready: Ready to start a download.
    /// - queued: Download is queued to be downloaded.
    /// - downloading: Download is currently in progress; the setProgress method is available.
    /// - complete: Download is complete.
    public enum DownloadState {
        case ready
        case queued
        case downloading
        case complete
    }

    /// Get or set the current download state being rendered.
    public var downloadState: DownloadState = .ready {
        didSet {
            setupView()
        }
    }

    /// Reset the progress bar state if the downloadState is .downloading.
    public func resetProgress() {
        self.progress = 0
        setProgress(to: 0, withAnimation: false)
    }

    /// Set the progress bar state if the downloadState is .downloading.
    public func setProgress(to progressConstant: Double, withAnimation: Bool) {
        let progress = min(max(progressConstant, 0), 1) // clamp 0...1

        foregroundLayer.strokeEnd = CGFloat(progress)
        foregroundLayer.removeAllAnimations()

        if withAnimation {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = self.progress
            animation.toValue = progress
            animation.duration = 0.7
            foregroundLayer.add(animation, forKey: "foregroundAnimation")
        }

        self.progress = progress
    }

    // MARK: - Private Properties -

    private enum IconAssets: String {
        case ready    = "downloadctrl_ready"
        case complete = "downloadctrl_complete"
    }

    private let backgroundLayer = CAShapeLayer()
    private let foregroundLayer = CAShapeLayer()

    private var lineWidth:CGFloat = 2 {
        didSet{
            foregroundLayer.lineWidth = lineWidth
            backgroundLayer.lineWidth = lineWidth - (0.5 * lineWidth)
        }
    }

    private var pathCenter: CGPoint {
        get {
            return self.convert(self.center, from:self.superview)
        }
    }

    private var progress: Double = 0

    private var radius: CGFloat {
        get{
            return self.frame.width < self.frame.height
                ? (self.frame.width  - lineWidth) / 2
                : (self.frame.height - lineWidth) / 2
        }
    }

    // MARK: - Private Methods -

    private func setupView() {
        self.layer.sublayers = nil
        self.backgroundLayer.frame = self.bounds
        self.foregroundLayer.frame = self.bounds

        drawBackgroundLayer()
        drawForegroundLayer()
    }

    private func drawBackgroundLayer(){
        backgroundLayer.sublayers?.removeAll()
        drawBackground(for: self.downloadState)
        self.layer.addSublayer(backgroundLayer)
    }

    private func drawForegroundLayer(){
        if downloadState != .downloading { return }

        let startAngle = (-CGFloat.pi / 2)
        let endAngle = 2 * CGFloat.pi + startAngle
        let path = UIBezierPath(
            arcCenter: pathCenter, radius: self.radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)

        foregroundLayer.path = path.cgPath
        foregroundLayer.lineWidth = lineWidth
        foregroundLayer.fillColor = UIColor.clear.cgColor
        foregroundLayer.strokeColor = self.tintColor.cgColor
        foregroundLayer.strokeEnd = 0

        self.layer.addSublayer(foregroundLayer)
    }

    // MARK: - Drawing -

    private func drawBackground(for state: DownloadState) {
        switch state {
        case .ready:
            drawReadyState(
                background: self.backgroundLayer,
                tint: self.tintColor)
        case .queued:
            drawQueuedState(
                background: self.backgroundLayer,
                tint: self.tintColor,
                center: self.pathCenter,
                radius: self.radius,
                lineWidth: self.lineWidth)
        case .downloading:
            drawDownloadingState(
                background: self.backgroundLayer,
                tint: self.tintColor,
                center: self.pathCenter,
                radius: self.radius,
                lineWidth: self.lineWidth)
        case .complete:
            drawCompleteState(background: self.backgroundLayer, tint: self.tintColor)
        }
    }

    private func drawReadyState(background: CALayer, tint: UIColor) {
        drawImage(asset: IconAssets.ready, to: background, with: tint)
    }

    private func drawQueuedState(
        background: CALayer, tint: UIColor, center: CGPoint, radius: CGFloat, lineWidth: CGFloat) {

        let rad = radius + (radius * 0.1)
        let width = lineWidth * 0.5

        drawSquare(to: background, with: tint, center: center, radius: rad)
        drawCircle(to: background, with: tint, center: center, radius: rad, lineWidth: width, dashed: true)
    }

    private func drawDownloadingState(
        background: CALayer, tint: UIColor, center: CGPoint, radius: CGFloat, lineWidth: CGFloat) {

        let rad = radius + (radius * 0.1)
        let width = lineWidth * 0.2

        drawSquare(to: background, with: tint, center: center, radius: rad)
        drawCircle(to: background, with: tint, center: center, radius: rad, lineWidth: width)
    }

    private func drawCompleteState(background: CALayer, tint: UIColor) {
        drawImage(asset: IconAssets.complete, to: background, with: tint)
    }

    // MARK: - Helpers -

    private func drawImage(asset: IconAssets, to layer: CALayer, with tint: UIColor) {
        let image = UIImage(named: asset.rawValue, in: Bundle(for: DownloadButton.self), compatibleWith: nil)!.cgImage!

        let imageMaskLayer = CALayer()
        imageMaskLayer.frame = layer.frame
        imageMaskLayer.contentsGravity = CALayerContentsGravity.center
        imageMaskLayer.contentsScale = CGFloat(integerLiteral: image.height) / layer.bounds.height
        imageMaskLayer.contents = image

        let imageLayer = CALayer()
        imageLayer.frame = layer.frame
        imageLayer.mask = imageMaskLayer
        imageLayer.backgroundColor = tint.cgColor

        layer.addSublayer(imageLayer)
    }

    private func drawCircle(
        to layer: CALayer, with tint: UIColor, center: CGPoint, radius: CGFloat, lineWidth: CGFloat,
        dashed: Bool = false) {

        let circlePath = UIBezierPath(
            arcCenter: center, radius: radius, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)

        let circleLayer = CAShapeLayer()
        circleLayer.path = circlePath.cgPath
        circleLayer.strokeColor = tint.cgColor
        circleLayer.lineWidth = lineWidth
        circleLayer.fillColor = UIColor.clear.cgColor

        if dashed {
            circleLayer.lineDashPattern = [4, 2] // ----  ----  ----
        }

        layer.addSublayer(circleLayer)
    }

    private func drawSquare(to layer: CALayer, with tint: UIColor, center: CGPoint, radius: CGFloat) {
        let stopLayer = CAShapeLayer()
        let stopStride = radius * 0.75
        let stopHalfStride = stopStride * 0.5
        let stopPath = UIBezierPath(rect: CGRect(
            x: center.x - stopHalfStride,
            y: center.y - stopHalfStride,
            width: stopStride,
            height: stopStride))
        stopLayer.path = stopPath.cgPath
        stopLayer.fillColor = tint.cgColor

        layer.addSublayer(stopLayer)
    }
}
