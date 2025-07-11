//
//  ContentDetection.swift
//  TemplifyApp
//
//  Created by Alex Atamanskyi on 10.07.2025.
//  Copyright © 2025 Templify Media, Inc. All rights reserved.
//

import Foundation
import UIKit

protocol ContentDetection {
    var name: String { get }
    func analyze(fileURL: URL?, imageFrames: [UIImage]) async -> DetectionStatus
}

enum DetectionStatus: Equatable {
    case passed
    case failed(reason: String)
}
