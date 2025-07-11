//
//  NSFWContentDetector.swift
//  TemplifyApp
//
//  Created by sasha ataman on 10.07.2025.
//  Copyright © 2025 Templify Media, Inc. All rights reserved.
//

import Vision
import CoreFoundation
import UIKit

class NSFWContentDetector: ContentDetection {
    let name = "NSFWContentDetector"

    private let model = try? VNCoreMLModel(for: NSFW(configuration: .init()).model)

    func analyze(fileURL: URL?, imageFrames: [UIImage]) async -> DetectionStatus {
        let start = CFAbsoluteTimeGetCurrent()

        for frame in imageFrames {
            guard let cgImage = frame.cgImage,
                    let model = model else { continue }
            let request = VNCoreMLRequest(model: model)
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try? handler.perform([request])
            if let observations = request.results as? [VNClassificationObservation],
               let nsfwObs = observations.first(where: { $0.identifier == "NSFW" }),
               nsfwObs.confidence > 0.85 {
                debugPrint("[NSFWContentDetector] Detected at confidence: \(nsfwObs.confidence)")
                logTime("NSFW Detection", from: start)
                return .failed(reason: "NSFW content detected")
            }
        }

        logTime("NSFW Detection", from: start)
        return .passed
    }
}
