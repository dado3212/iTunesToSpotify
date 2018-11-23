//
//  Extensions.swift
//  iTunesToSpotify
//
//  Created by Alex Beals on 11/22/18.
//  Copyright © 2018 Alex Beals. All rights reserved.
//

import Foundation
import AppKit
import Cocoa

extension NSImage {
    func imageTintedWithColor(_ tint: NSColor) -> NSImage {
        guard let tinted = self.copy() as? NSImage else { return self }
        tinted.lockFocus()
        tint.set()

        let imageRect = NSRect(origin: NSZeroPoint, size: self.size)
        __NSRectFillUsingOperation(imageRect, .sourceAtop)

        tinted.unlockFocus()
        return tinted
    }
}
