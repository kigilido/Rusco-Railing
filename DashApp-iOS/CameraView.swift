//
//  CameraView.swift
//  DashApp iOS
//
//  Native camera view with license plate overlay guides
//

import SwiftUI
import AVFoundation

struct CameraView: UIViewControllerRepresentable {
    var onCapture: (UIImage) -> Void

    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()
        controller.onCapture = onCapture
        return controller
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
}

class CameraViewController: UIViewController {
    var onCapture: ((UIImage) -> Void)?

    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var photoOutput: AVCapturePhotoOutput?

    private let shutterButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.layer.cornerRadius = 35
        button.layer.borderWidth = 4
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let flashButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "bolt.slash.fill"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private var flashMode: AVCaptureDevice.FlashMode = .off

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupUI()
    }

    private func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = .photo

        guard let videoCaptureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }

        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if captureSession?.canAddInput(videoInput) == true {
            captureSession?.addInput(videoInput)
        }

        photoOutput = AVCapturePhotoOutput()
        if captureSession?.canAddOutput(photoOutput!) == true {
            captureSession?.addOutput(photoOutput!)
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        previewLayer?.frame = view.layer.bounds
        previewLayer?.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer!)

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.startRunning()
        }
    }

    private func setupUI() {
        // Add overlay guide for license plate
        let overlayView = LicensePlateOverlay()
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlayView)

        // Add buttons
        view.addSubview(shutterButton)
        view.addSubview(cancelButton)
        view.addSubview(flashButton)

        NSLayoutConstraint.activate([
            // Overlay
            overlayView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            overlayView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            overlayView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            overlayView.heightAnchor.constraint(equalTo: overlayView.widthAnchor, multiplier: 0.4),

            // Shutter button
            shutterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shutterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            shutterButton.widthAnchor.constraint(equalToConstant: 70),
            shutterButton.heightAnchor.constraint(equalToConstant: 70),

            // Cancel button
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            cancelButton.centerYAnchor.constraint(equalTo: shutterButton.centerYAnchor),

            // Flash button
            flashButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            flashButton.centerYAnchor.constraint(equalTo: shutterButton.centerYAnchor),
        ])

        shutterButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelCamera), for: .touchUpInside)
        flashButton.addTarget(self, action: #selector(toggleFlash), for: .touchUpInside)
    }

    @objc private func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = flashMode
        photoOutput?.capturePhoto(with: settings, delegate: self)
    }

    @objc private func cancelCamera() {
        dismiss(animated: true)
    }

    @objc private func toggleFlash() {
        flashMode = flashMode == .off ? .on : .off
        let iconName = flashMode == .on ? "bolt.fill" : "bolt.slash.fill"
        flashButton.setImage(UIImage(systemName: iconName), for: .normal)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession?.stopRunning()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.layer.bounds
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else { return }

        onCapture?(image)
        dismiss(animated: true)
    }
}

// MARK: - License Plate Overlay
class LicensePlateOverlay: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        // Draw semi-transparent background
        context.setFillColor(UIColor.black.withAlphaComponent(0.5).cgColor)
        context.fill(bounds)

        // Cut out center rectangle for license plate
        let plateRect = CGRect(
            x: bounds.width * 0.1,
            y: bounds.height * 0.2,
            width: bounds.width * 0.8,
            height: bounds.height * 0.6
        )

        context.setBlendMode(.clear)
        context.fill(plateRect)
        context.setBlendMode(.normal)

        // Draw corner guides
        context.setStrokeColor(UIColor.white.cgColor)
        context.setLineWidth(3)

        let cornerLength: CGFloat = 20

        // Top-left
        context.move(to: CGPoint(x: plateRect.minX, y: plateRect.minY + cornerLength))
        context.addLine(to: CGPoint(x: plateRect.minX, y: plateRect.minY))
        context.addLine(to: CGPoint(x: plateRect.minX + cornerLength, y: plateRect.minY))

        // Top-right
        context.move(to: CGPoint(x: plateRect.maxX - cornerLength, y: plateRect.minY))
        context.addLine(to: CGPoint(x: plateRect.maxX, y: plateRect.minY))
        context.addLine(to: CGPoint(x: plateRect.maxX, y: plateRect.minY + cornerLength))

        // Bottom-left
        context.move(to: CGPoint(x: plateRect.minX, y: plateRect.maxY - cornerLength))
        context.addLine(to: CGPoint(x: plateRect.minX, y: plateRect.maxY))
        context.addLine(to: CGPoint(x: plateRect.minX + cornerLength, y: plateRect.maxY))

        // Bottom-right
        context.move(to: CGPoint(x: plateRect.maxX - cornerLength, y: plateRect.maxY))
        context.addLine(to: CGPoint(x: plateRect.maxX, y: plateRect.maxY))
        context.addLine(to: CGPoint(x: plateRect.maxX, y: plateRect.maxY - cornerLength))

        context.strokePath()

        // Draw instruction text
        let text = "Align license plate within frame"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor.white
        ]
        let textSize = text.size(withAttributes: attributes)
        let textRect = CGRect(
            x: (bounds.width - textSize.width) / 2,
            y: plateRect.maxY + 20,
            width: textSize.width,
            height: textSize.height
        )
        text.draw(in: textRect, withAttributes: attributes)
    }
}
