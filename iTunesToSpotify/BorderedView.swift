//
//  BorderedView.swift
//  iTunesToSpotify
//
//  Created by Alex Beals on 11/22/18.
//  Copyright © 2018 Alex Beals. All rights reserved.
//

import AppKit

class BorderedView: NSView {
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // dash customization parameters
        let dashHeight: CGFloat = 3
        let dashLength: CGFloat = 10
        let dashColor: NSColor = .white

        // setup the context
        let currentContext = NSGraphicsContext.current!.cgContext
        currentContext.setLineWidth(dashHeight)
        currentContext.setLineDash(phase: 0, lengths: [dashLength])
        currentContext.setStrokeColor(dashColor.cgColor)

        // draw the dashed path
        currentContext.addRect(bounds.insetBy(dx: dashHeight, dy: dashHeight))
        currentContext.strokePath()
    }
}
