//
//  ContentBlockerManager.swift
//  TemplifyApp
//
//  Created by Alex Atamanskyi on 10.07.2025.
//  Copyright © 2025 Templify Media, Inc. All rights reserved.
//
import UIKit
import AVFoundation

open class ContentBlockerManager {
    private let detectors: [ContentDetection] = [
        HateSpeechDetector(),
        NSFWContentDetector(),
        ViolenceContentDetector()
    ]

    private(set) var lastResults: [String: DetectionStatus] = [:]
    
    public init() {}

    public func verifyContent(from fileURL: URL, mediaType: ContentBlockerManager.ContentType) async -> Bool {
        let start = CFAbsoluteTimeGetCurrent()
        lastResults = [:]

        let frames: [UIImage]

        switch mediaType {
        case .video:
            frames = await extractFrames(from: fileURL)
        case .image:
            guard let image = UIImage(contentsOfFile: fileURL.path) else {
                debugPrint("Failed to load image from path")
                return false
            }
            frames = [image]
        }

        for detector in detectors {
            let result = await detector.analyze(fileURL: fileURL,
                                                imageFrames: frames)
            lastResults[detector.name] = result
        }

        let totalTime = CFAbsoluteTimeGetCurrent() - start
        debugPrint("Total Time: \(totalTime.rounded(to: 3))s")

        return lastResults.values.allSatisfy { $0 == .passed }
    }

    public func getFailureReasons() -> [String] {
        lastResults.compactMap { detectorName, status in
            switch status {
            case .passed:
                return nil
            case .failed(let reason):
                return "\(detectorName): \(reason)"
            }
        }
    }

    private func extractFrames(from videoURL: URL) async -> [UIImage] {
        do {
            let asset = AVAsset(url: videoURL)
            let duration = try await asset.load(.duration)
            let durationSeconds = CMTimeGetSeconds(duration)

            let frameCount = 10
            let ratios = [0.0] + (1...frameCount).map { Double($0) / Double(frameCount + 1) } + [1.0]
            let times = ratios.map {
                CMTime(seconds: durationSeconds * $0,
                                            preferredTimescale: 600)
            }

            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true

            var images: [UIImage] = []

            for time in times {
                do {
                    let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
                    let uiImage = UIImage(cgImage: cgImage)
                    images.append(uiImage)

                    // uncomment for testing
//                    UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
//                    debugPrint("Saved frame \(index) to Photos")
                } catch {
                    debugPrint("Failed to extract frame at \(time.seconds)s: \(error.localizedDescription)")
                }
            }

            return images
        } catch {
            debugPrint("Failed to get duration time \(error)")
            return []
        }
    }
}

extension ContentBlockerManager {
    public enum ContentType {
        case video
        case image
    }
}
