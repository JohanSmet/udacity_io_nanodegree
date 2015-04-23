//
//  RecordedAudio.swift
//  Pitch Perfect
//
//  Created by Johan Smet on 21/04/15.
//  Copyright (c) 2015 JustCode. All rights reserved.
//

import Foundation

class RecordedAudio: NSObject {
    
    init(filePathUrl: NSURL, title: String) {
        self.filePathUrl = filePathUrl
        self.title = title
    }
    
    var filePathUrl: NSURL
    var title: String
}
