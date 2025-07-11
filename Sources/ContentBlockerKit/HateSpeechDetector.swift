//
//  HateSpeechDetector.swift
//  TemplifyApp
//
//  Created by sasha ataman on 10.07.2025.
//  Copyright © 2025 Templify Media, Inc. All rights reserved.
//

import UIKit
import CoreFoundation
import Vision
import NaturalLanguage
import Speech

class HateSpeechDetector: ContentDetection {
    let name = "HateSpeechDetector"

    private let model = try? HateSpeach(configuration: .init())

    func analyze(fileURL: URL?, imageFrames: [UIImage]) async -> DetectionStatus {
        let start = CFAbsoluteTimeGetCurrent()

        var combinedText = ""

        for frame in imageFrames {
            guard let cgImage = frame.cgImage else { continue }

            let request = VNRecognizeTextRequest()
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try? handler.perform([request])

            let text = (request.results)?
                .compactMap { $0.topCandidates(1).first?.string }
                .joined(separator: " ") ?? ""

            combinedText += text + " "
        }

        if let fileURL {
            do {
                let audioText = try await transcribeAudio(from: fileURL)
                combinedText += audioText
            } catch {
                debugPrint("[HateSpeechDetector] Audio transcription failed: \(error)")
            }
        }

        guard let rollModel = try? NLModel(mlModel: model?.model ?? MLModel()) else {
            return .failed(reason: "Failed to load hate speech model")
        }

        let predictions = rollModel.predictedLabelHypotheses(for: combinedText, maximumCount: 1)
        if let hateScore = predictions["hate"], hateScore > 0.95 {
            debugPrint("[HateSpeechDetector] Detected at confidence: \(hateScore)")
            logTime("Hate Speech Detection", from: start)
            return .failed(reason: "Hate speech detected")
        }

        logTime("Hate Speech Detection", from: start)
        return .passed
    }

    private func transcribeAudio(from url: URL) async throws -> String {
        let recognizer = SFSpeechRecognizer()
        let request = SFSpeechURLRecognitionRequest(url: url)

        return try await withCheckedThrowingContinuation { continuation in
            recognizer?.recognitionTask(with: request) { result, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let result, result.isFinal {
                    continuation.resume(returning: result.bestTranscription.formattedString)
                }
            }
        }
    }
}
