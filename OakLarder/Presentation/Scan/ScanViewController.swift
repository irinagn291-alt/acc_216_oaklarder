import AVFoundation
import UIKit
import SnapKit

final class ScanViewController: UIViewController, ScanViewProtocol {
    var presenter: ScanPresenterProtocol?

    private let session = AVCaptureSession()
    private let preview = AVCaptureVideoPreviewLayer()
    private let frameArt = UIImageView(image: UIImage(named: "ChromeIronFrame"))
    private let field = IronField(placeholder: "Manual EAN / URL", keyboard: .numbersAndPunctuation)
    private let lookup = BrassButton(title: "Look up stamp")
    private let status = UILabel()
    private var sessionReady = false

    override func viewDidLoad() {
        super.viewDidLoad()
        oakBackground("TexBrushedIron")
        oakTitleBar("Stamp the crate")
        preview.videoGravity = .resizeAspectFill
        let cameraBox = UIView()
        cameraBox.layer.cornerRadius = 12
        cameraBox.clipsToBounds = true
        cameraBox.backgroundColor = OakPalette.iron
        cameraBox.layer.addSublayer(preview)
        frameArt.contentMode = .scaleAspectFill
        status.font = OakType.regular(13)
        status.textColor = OakPalette.parchment
        status.numberOfLines = 0
        status.textAlignment = .center
        field.returnKeyType = .go
        field.delegate = self
        lookup.addTarget(self, action: #selector(manual), for: .touchUpInside)
        view.addSubview(cameraBox)
        view.addSubview(frameArt)
        view.addSubview(field)
        view.addSubview(lookup)
        view.addSubview(status)
        cameraBox.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(68)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(cameraBox.snp.width)
        }
        frameArt.snp.makeConstraints { $0.edges.equalTo(cameraBox).inset(-6) }
        field.snp.makeConstraints { make in
            make.top.equalTo(cameraBox.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }
        lookup.snp.makeConstraints { make in
            make.top.equalTo(field.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        status.snp.makeConstraints { make in
            make.top.equalTo(lookup.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        view.bringSubviewToFront(frameArt)
        askCamera(in: cameraBox)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        preview.frame = preview.superlayer?.bounds ?? .zero
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if session.isRunning {
            DispatchQueue.global(qos: .userInitiated).async { [session] in
                session.stopRunning()
            }
        }
    }

    func render(_ entity: ScanEntity) {
        status.text = entity.message
        if let code = entity.normalized {
            field.text = code
        }
    }

    @objc private func manual() {
        presenter?.lookupManual(field.text ?? "")
    }

    private func askCamera(in box: UIView) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configure(in: box)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                Task { @MainActor in
                    if granted { self?.configure(in: box) }
                    else { self?.status.text = "Camera closed — type the EAN" }
                }
            }
        default:
            status.text = "Camera closed — type the EAN"
        }
    }

    private func configure(in box: UIView) {
        guard !sessionReady, let device = AVCaptureDevice.default(for: .video) else {
            status.text = "No lens here — type the EAN"
            return
        }
        session.beginConfiguration()
        session.inputs.forEach { session.removeInput($0) }
        session.outputs.forEach { session.removeOutput($0) }
        guard let input = try? AVCaptureDeviceInput(device: device), session.canAddInput(input) else {
            session.commitConfiguration()
            status.text = "Lens busy — type the EAN"
            return
        }
        session.addInput(input)
        let output = AVCaptureMetadataOutput()
        guard session.canAddOutput(output) else {
            session.commitConfiguration()
            return
        }
        session.addOutput(output)
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.metadataObjectTypes = output.availableMetadataObjectTypes.filter {
            [.ean8, .ean13, .upce, .code128, .qr].contains($0)
        }
        session.commitConfiguration()
        preview.session = session
        preview.frame = box.bounds
        sessionReady = true
        DispatchQueue.global(qos: .userInitiated).async { [session] in
            session.startRunning()
        }
    }
}

extension ScanViewController: AVCaptureMetadataOutputObjectsDelegate, UITextFieldDelegate {
    nonisolated func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let raw = object.stringValue
        else { return }
        Task { @MainActor [weak self] in
            self?.presenter?.didReadStamp(raw)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        manual()
        return true
    }
}
