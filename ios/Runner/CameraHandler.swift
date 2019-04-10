//
//  CameraHandler.swift
//  Runner
//
//  Created by Ryan Paglinawan on 4/8/19.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewFactory: NSObject, FlutterPlatformViewFactory {
    
    public var _uiCameraHandle: UICameraView
    
    override init() {
        _uiCameraHandle = UICameraView(CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0), viewID: 0, args: nil)
    }
    
    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        _uiCameraHandle = UICameraView(frame, viewID: viewId, args: args)
        return _uiCameraHandle
    }
}

class UICameraView: NSObject, FlutterPlatformView {
    let frame: CGRect
    let viewId: Int64
    
    lazy public var _customCamera: CustomCameraView = {
        let camera = CustomCameraView(frame: self.frame)
        return camera
    }()
    
    init(_ frame: CGRect, viewID: Int64, args: Any?) {
        self.viewId = viewID
        self.frame = frame
    }
    
    func view() -> UIView {
        return _customCamera
    }
}

class CustomCameraView: UIView {
    
    public var imageData: Data = Data()
    
    var cameraConnection: CameraHandle = CameraHandle()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureConfiguration()
    }
    
    func takePicture(completion: @escaping(Data?, Error?) -> Void) {
        self.cameraConnection.captureImage {
            (image, Error) in
            guard let _image = image else {
                print(Error ?? "Error in Camera capture")
                return
            }
            self.imageData = UIImagePNGRepresentation(_image)!
            
            return
        }
    }
    
    func configureConfiguration(){
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            cameraConnection.prepare{(error) in
                if let error = error {
                    print(error)
                }
                try? self.cameraConnection.displayPreview(on: self)
            }
            break
        case .notDetermined:
            cameraConnection.sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video, completionHandler: {granted in
                if !granted {
                    
                }
            })
        default:
            cameraConnection.sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video, completionHandler: {granted in
                if !granted {
                    
                }
            })
        }
    }
    
    func cleanUp(){
        self.cameraConnection.closeSession()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CameraHandle: NSObject {
    
    var captureSession: AVCaptureSession?
    
    var currentCameraPosition: CameraPosition?
    
    var frontCamera: AVCaptureDevice?
    var frontCameraInput: AVCaptureDeviceInput?
    
    var photoOutput: AVCapturePhotoOutput?
    
    var rearCamera: AVCaptureDevice?
    var rearCameraInput: AVCaptureDeviceInput?
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var flashMode = AVCaptureDevice.FlashMode.off
    var photoCaptureCompletionBlock: ((UIImage?, Error?) -> Void)?
    var capturedImage: UIImage?
    
    let sessionQueue = DispatchQueue(label: "prepareSession")
    
    let outputSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
    let stillOutput = AVCapturePhotoOutput()
    let camSettings = AVCapturePhotoSettings()
    
    func prepare(completionHandler: @escaping (Error?) -> Void) {
        self.captureSession = AVCaptureSession()
        func createSession() {
            captureSession?.beginConfiguration()
            captureSession?.automaticallyConfiguresCaptureDeviceForWideColor = true
        }
        
        //        Standard image capture
        func configureCaptureDevices() throws {
            //            TODO: add depth data
            
            let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInTelephotoCamera], mediaType: AVMediaType.video, position: .unspecified)
            let cameras = (session.devices.compactMap{$0})
            
            guard !cameras.isEmpty else {throw CameraAccessError.noCamerasAvailable}
            for camera in cameras {
                switch (camera.position) {
                case .front:
                    self.frontCamera = camera
                    break
                case .back:
                    self.rearCamera = camera
                    try camera.lockForConfiguration()
                    camera.focusMode = .continuousAutoFocus
                    camera.unlockForConfiguration()
                    break
                case .unspecified:
                    print("unspecified camera")
                    throw CameraAccessError.inputsAreInvalid
                default:
                    throw CameraAccessError.invalidOperation
                }
                
            }
        }
        
        func configureDeviceInputs() throws {
            guard let captureSession = self.captureSession else {throw CameraAccessError.captureSessionIsMissing}
            if let rearCamera = self.rearCamera {
                self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
                
                if captureSession.canAddInput(self.rearCameraInput!){
                    captureSession.addInput(self.rearCameraInput!)
                }
                
                self.currentCameraPosition = .rear
                
            }
            else if let frontCamera = self.frontCamera {
                self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
                
                if captureSession.canAddInput(self.frontCameraInput!) {
                    captureSession.addInput(self.frontCameraInput!)
                }
                
                self.currentCameraPosition = .front
            }
            else {throw CameraAccessError.noCamerasAvailable}
        }
        
        func configurePhotoOutputs() throws {
            guard let captureSession = self.captureSession else {
                throw CameraAccessError.captureSessionIsMissing
            }
            self.photoOutput = AVCapturePhotoOutput()
            self.photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
            if captureSession.canAddOutput(self.photoOutput!) {
                captureSession.addOutput(self.photoOutput!)
            }
            self.captureSession?.commitConfiguration()
        }
        
        sessionQueue.async {
            do {
                
                //                guard let captureSession = self.captureSession else {
                //                    throw CameraAccessError.captureSessionIsMissing
                //                }
                if !(self.captureSession?.isRunning)! {
                    self.captureSession?.startRunning()
                }
                createSession()
                try configureCaptureDevices()
                try configureDeviceInputs()
                try configurePhotoOutputs()
            }
            catch {
                DispatchQueue.main.async {
                    completionHandler(error)
                }
                return
            }
            DispatchQueue.main.async {
                completionHandler(nil)
            }
        }
    }
    
    func displayPreview(on calledView: UIView) throws {
        guard let captureSession = self.captureSession, captureSession.isRunning else { throw CameraAccessError.captureSessionIsMissing }
        calledView.tag = 500
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspect
        self.previewLayer?.connection?.videoOrientation = .portrait
        self.previewLayer?.frame = calledView.frame
        
        calledView.layer.insertSublayer(self.previewLayer!, at: 0)
        
    }
    
    func captureImage(completion: @escaping (UIImage?, Error?) -> Void) {
        guard let captureSession = captureSession, captureSession.isRunning else {completion (nil, CameraAccessError.captureSessionIsMissing); return}
        let settings = AVCapturePhotoSettings()
        settings.flashMode = self.flashMode
        settings.isAutoStillImageStabilizationEnabled = true
        
        captureSession.commitConfiguration()
        
        self.photoOutput?.capturePhoto(with: settings, delegate: self)
        self.photoCaptureCompletionBlock = completion
    }
    
    func closeSession() {
        //        try to stop camera
        
        self.captureSession?.stopRunning()
        
        if let inputs = captureSession?.inputs {
            for input in inputs {
                self.captureSession?.removeInput(input)
            }
        }
    }
}

extension CameraHandle: AVCapturePhotoCaptureDelegate {
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if let error = error {
            self.photoCaptureCompletionBlock?(nil, error)
        }
        else if let buffer = photoSampleBuffer, let data = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: buffer, previewPhotoSampleBuffer: nil), let image = UIImage(data: data) {
            self.photoCaptureCompletionBlock?(image, nil)
        }
        else {
            self.photoCaptureCompletionBlock?(nil, CameraAccessError.unknown)
        }
    }
}

extension CameraHandle {
    enum CameraAccessError: Swift.Error {
        case noAccessCamera
        case noPermissionCamera
        case noStreamCamera
        case captureSessionIsMissing
        case unknown
        case noCamerasAvailable
        case inputsAreInvalid
        case invalidOperation
    }
    public enum CameraPosition {
        case rear
        case wide
        case tele
        case front
    }
}
