//
//  UIImage+Extension.swift
//  TemplifyApp
//
//  Created by Alex Atamanskyi on 10.07.2025.
//  Copyright © 2025 Templify Media, Inc. All rights reserved.
//
import UIKit

extension UIImage {
    func resizeAspectFitInfo(to targetSize: CGSize) -> UIImage? {
        let aspectWidth = targetSize.width / size.width
        let aspectHeight = targetSize.height / size.height
        let scale = min(aspectWidth, aspectHeight)

        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let xOffset = (targetSize.width - newSize.width) / 2.0
        let yOffset = (targetSize.height - newSize.height) / 2.0

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true
        format.preferredRange = .standard

        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        let resizedImage = renderer.image { _ in
            UIColor.black.setFill()
            UIBezierPath(rect: CGRect(origin: .zero, size: targetSize)).fill()
            self.draw(in: CGRect(origin: CGPoint(x: xOffset, y: yOffset), size: newSize))
        }

        return resizedImage
    }

    func pixelBuffer() -> CVPixelBuffer? {
        let width = 640
        let height = 640
        let attrs: [CFString: Any] = [
            kCVPixelBufferCGImageCompatibilityKey: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey: true
        ]
        var pxbuffer: CVPixelBuffer?

        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            kCVPixelFormatType_32ARGB,
            attrs as CFDictionary,
            &pxbuffer)

        guard status == kCVReturnSuccess, let pixelBuffer = pxbuffer else {
            return nil
        }

        CVPixelBufferLockBaseAddress(pixelBuffer, [])

        let pxData = CVPixelBufferGetBaseAddress(pixelBuffer)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()

        guard let context = CGContext(
            data: pxData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
            space: rgbColorSpace,
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        else {
            return nil
        }

        UIGraphicsPushContext(context)
        self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        UIGraphicsPopContext()

        CVPixelBufferUnlockBaseAddress(pixelBuffer, [])

        return pixelBuffer
    }
}
