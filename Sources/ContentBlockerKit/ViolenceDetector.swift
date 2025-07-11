//
//  ViolenceContentDetector.swift
//  TemplifyApp
//
//  Created by Alex Atamanskyi on 10.07.2025.
//  Copyright © 2025 Templify Media, Inc. All rights reserved.
//
import UIKit

class ViolenceContentDetector: ContentDetection {
    let name = "ViolenceContentDetector"

    private let model = try? yolo_small_weights(configuration: .init())

    func analyze(fileURL: URL?, imageFrames: [UIImage]) async -> DetectionStatus {
        let start = CFAbsoluteTimeGetCurrent()

        for frame in imageFrames {
            guard let resizeInfo = frame.resizeAspectFitInfo(to: CGSize(width: 640, height: 640)),
                  let pixelBuffer = resizeInfo.pixelBuffer() else {
                continue
            }

            let prediction = try? model?.prediction(
                image: pixelBuffer,
                iouThreshold: 0.7,
                confidenceThreshold: 0.25
            )

            let numDetections = prediction?.confidence.shape[0].intValue ?? 0
            for detection in 0..<numDetections {
                let violenceScore = prediction?.confidence[[NSNumber(value: detection), 1]].doubleValue ?? 0.0
                if violenceScore > 0.8 {
                    debugPrint("[ViolenceContentDetector] Detected at confidence: \(violenceScore)")
                    logTime("Violence Detection", from: start)
                    return .failed(reason: "Violence detected")
                }
            }
        }

        logTime("Violence Detection", from: start)
        return .passed
    }
}
