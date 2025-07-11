//
//  logTime.swift
//  TemplifyApp
//
//  Created by Alex Atamanskyi on 10.07.2025.
//  Copyright © 2025 Templify Media, Inc. All rights reserved.
//

import CoreFoundation

func logTime(_ label: String, from start: CFAbsoluteTime) {
    let end = CFAbsoluteTimeGetCurrent()
    debugPrint("\(label): \((end - start).rounded(to: 3))s")
}
