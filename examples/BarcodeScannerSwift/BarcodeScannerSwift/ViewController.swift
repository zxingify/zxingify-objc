/*
 * Copyright 2012 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import UIKit
import ZXingObjC

class ViewController: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var scanView: UIView?
    @IBOutlet weak var resultLabel: UILabel?
    
    fileprivate var capture: ZXCapture?
    
    fileprivate var isScanning: Bool?
    fileprivate var isFirstApplyOrientation: Bool?
    
    
    // MARK: Life Circles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if isFirstApplyOrientation == true { return }
        isFirstApplyOrientation = true
        applyOrientation()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { (context) in
            // do nothing
        }) { [weak self] (context) in
            guard let weakSelf = self else { return }
            weakSelf.applyOrientation()
        }
    }
}

// MARK: Helpers
extension ViewController {
    func setup() {
        isScanning = false
        isFirstApplyOrientation = false
        
        capture = ZXCapture()
        guard let _capture = capture else { return }
        _capture.camera = _capture.back()
        _capture.focusMode =  .continuousAutoFocus
        _capture.delegate = self
        
        self.view.layer.addSublayer(_capture.layer)
        guard let _scanView = scanView, let _resultLabel = resultLabel else { return }
        self.view.bringSubview(toFront: _scanView)
        self.view.bringSubview(toFront: _resultLabel)
    }
    
    func applyOrientation() {
        let orientation = UIApplication.shared.statusBarOrientation
        var captureRotation: Double
        var scanRectRotation: Double
        
        switch orientation {
            case .portrait:
                captureRotation = 0
                scanRectRotation = 90
                break
            
            case .landscapeLeft:
                captureRotation = 90
                scanRectRotation = 180
                break
            
            case .landscapeRight:
                captureRotation = 270
                scanRectRotation = 0
                break
            
            case .portraitUpsideDown:
                captureRotation = 180
                scanRectRotation = 270
                break
            
            default:
                captureRotation = 0
                scanRectRotation = 90
                break
        }
        
        applyRectOfInterest(orientation: orientation)
        
        let angleRadius = captureRotation / 180.0 * Double.pi
        let captureTranform = CGAffineTransform(rotationAngle: CGFloat(angleRadius))
        
        capture?.transform = captureTranform
        capture?.rotation = CGFloat(scanRectRotation)
        capture?.layer.frame = view.frame
    }
    
    func applyRectOfInterest(orientation: UIInterfaceOrientation) {
        guard
            let capture = capture,
            let captureLayer = capture.layer as? AVCaptureVideoPreviewLayer,
            let scanRect = scanView?.frame
        else { return }
        
        let transformedScanRect: CGRect
        if orientation.isLandscape {
            transformedScanRect = CGRect(
                x: scanRect.origin.y,
                y: scanRect.origin.x,
                width: scanRect.size.height,
                height: scanRect.size.width
            )
        } else {
            transformedScanRect = scanRect
        }
        
        let metadataOutputRect = captureLayer.metadataOutputRectConverted(fromLayerRect: transformedScanRect)
        let rectOfInterest = capture.output.outputRectConverted(fromMetadataOutputRect: metadataOutputRect)
        capture.scanRect = rectOfInterest
    }
    
    func barcodeFormatToString(format: ZXBarcodeFormat) -> String {
        switch (format) {
            case kBarcodeFormatAztec:
                return "Aztec"
            
            case kBarcodeFormatCodabar:
                return "CODABAR"
            
            case kBarcodeFormatCode39:
                return "Code 39"
            
            case kBarcodeFormatCode93:
                return "Code 93"
            
            case kBarcodeFormatCode128:
                return "Code 128"
            
            case kBarcodeFormatDataMatrix:
                return "Data Matrix"
            
            case kBarcodeFormatEan8:
                return "EAN-8"
            
            case kBarcodeFormatEan13:
                return "EAN-13"
            
            case kBarcodeFormatITF:
                return "ITF"
            
            case kBarcodeFormatPDF417:
                return "PDF417"
            
            case kBarcodeFormatQRCode:
                return "QR Code"
            
            case kBarcodeFormatRSS14:
                return "RSS 14"
            
            case kBarcodeFormatRSSExpanded:
                return "RSS Expanded"
            
            case kBarcodeFormatUPCA:
                return "UPCA"
            
            case kBarcodeFormatUPCE:
                return "UPCE"
            
            case kBarcodeFormatUPCEANExtension:
                return "UPC/EAN extension"
            
            default:
                return "Unknown"
            }
    }
}

// MARK: ZXCaptureDelegate
extension ViewController: ZXCaptureDelegate {
    func captureCameraIsReady(_ capture: ZXCapture!) {
        isScanning = true
    }
    
    func captureResult(_ capture: ZXCapture!, result: ZXResult!) {
        guard let _result = result, isScanning == true else { return }

        capture?.stop()
        isScanning = false
        
        let text = _result.text ?? "Unknow"
        let format = barcodeFormatToString(format: _result.barcodeFormat)
        
        let displayStr = "Scanned !\nFormat: \(format)\nContents: \(text)"
        resultLabel?.text = displayStr
        
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.isScanning = true
            weakSelf.capture?.start()
        }
    }
    
}

