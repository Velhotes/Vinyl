//
//  URLSessionTaskType.swift
//  Vinyl
//
//  Created by David Rodrigues on 30/03/16.
//  Copyright © 2016 Velhotes. All rights reserved.
//

import Foundation

protocol URLSessionTaskType {
    init(completion: @escaping (Void) -> Void)
}
