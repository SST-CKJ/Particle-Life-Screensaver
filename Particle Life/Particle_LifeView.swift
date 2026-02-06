//
//  Particle_LifeView.swift
//  Particle Life
//
//  Created by CKJ on 1/2/26.
//

import ScreenSaver
import Foundation
import Cocoa

struct Particle {
    var x: CGFloat
    var y: CGFloat
    var vx: CGFloat
    var vy: CGFloat
    var type: Int
}

class Particle_LifeView: ScreenSaverView {
    
    // Can tweak these values to however you like
    private let particleRadius: CGFloat = 2.0       // Radius of each particle in pixels.

    private let numParticles = 1000                 // Total number of particles.
    private let numTypes = 6                        // Number of particle types/colours (higher means more complexity). If you increase this variable, add more colour(s) to the colors list below
    private let maxDistance: CGFloat = 60.0         // Maximum interaction range in pixels.
    private let forceFactor: CGFloat = 5.0          // Strength of forces
    private let beta: CGFloat = 0.2                 // Repulsion threshold to prevent particles from clumping up until it looks like a single particle
    private let frictionFactor: CGFloat = 0.94      // Velocity dampening (0.0 - 1.0, higher -> less friction)
    
    private var spatialGrid: [[Int]] = []           // For optimisation purposes
    private let cellSize: CGFloat = 70.0            // Must be adjusted to be slightly greater than maxDistance
    
    private var particles: [Particle] = []
    private var attractionMatrix: [[CGFloat]] = []
    
    private let colors: [NSColor] = [
        NSColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0),  // Red
        NSColor(red: 0.3, green: 1.0, blue: 0.3, alpha: 1.0),  // Green
        NSColor(red: 0.3, green: 0.3, blue: 1.0, alpha: 1.0),  // Blue
        NSColor(red: 1.0, green: 1.0, blue: 0.3, alpha: 1.0),  // Yellow
        NSColor(red: 0.5, green: 0.0, blue: 0.5, alpha: 1.0),  // Purple
        NSColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0),  // Orange
        NSColor(red: 0.3, green: 1.0, blue: 1.0, alpha: 1.0),  // Cyan
    ]
    
    
    static let NewInstanceNotification = Notification.Name("com.particlelife.newinstance")
    
    
    // Setup Functions
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        self.animationTimeInterval = 1.0 / 60.0
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.animationTimeInterval = 1.0 / 60.0
        setup()
    }
    
    private func generateAttractionMatrix() -> [[CGFloat]] {
        var matrix: [[CGFloat]] = []
        for _ in 0..<numTypes {
            var row: [CGFloat] = []
            for _ in 0..<numTypes {
                row.append(CGFloat.random(in: -1...1))
            }
            matrix.append(row)
        }
        return matrix
    }
    
    private func setup() {
        // For notifying cleanup function
        DistributedNotificationCenter.default.addObserver(
            self,
            selector: #selector(willStop(_:)),
            name: Notification.Name("com.apple.screensaver.willstop"),
            object: nil
        )
        
        // Generate random attraction matrix
        attractionMatrix = generateAttractionMatrix()
        
        // Create particles
        for _ in 0..<numParticles {
            particles.append(Particle(
                x: CGFloat.random(in: 0...bounds.width),
                y: CGFloat.random(in: 0...bounds.height),
                vx: 0,
                vy: 0,
                type: Int.random(in: 0..<numTypes)
            ))
        }
    }
    

    // Animating Functions
    override func animateOneFrame() {
        super.animateOneFrame()
        updateParticles()
        needsDisplay = true
        setNeedsDisplay(bounds)
    }
    
    private func updateSpatialGrid() {
        let cols = Int(ceil(bounds.width / cellSize))
        let rows = Int(ceil(bounds.height / cellSize))
        
        // Reset grid
        spatialGrid = Array(repeating: [], count: rows * cols)
        
        // Place particles in grid cells
        for (index, particle) in particles.enumerated() {
            let col = Int(particle.x / cellSize)
            let row = Int(particle.y / cellSize)
            let cellIndex = row * cols + col
            
            if cellIndex >= 0 && cellIndex < spatialGrid.count {
                spatialGrid[cellIndex].append(index)
            }
        }
    }

    private func updateParticles() {
        let dt: CGFloat = 1.0 / 60.0
        let halfWidth = bounds.width / 2
        let halfHeight = bounds.height / 2
        let maxDistSquared = maxDistance * maxDistance
        
        updateSpatialGrid()
        
        let cols = Int(ceil(bounds.width / cellSize))
        let rows = Int(ceil(bounds.height / cellSize))
        
        // Calculate forces and velocities
        for i in 0..<particles.count {
            var totalForceX: CGFloat = 0
            var totalForceY: CGFloat = 0
            
            // Find which cell this particle is in
            let col = Int(particles[i].x / cellSize)
            let row = Int(particles[i].y / cellSize)
            
            // Only check particles in nearby cells (3x3 grid around current cell)
            for dRow in -1...1 {
                for dCol in -1...1 {
                    let checkRow = row + dRow
                    let checkCol = col + dCol
                    
                    // Skip if out of bounds
                    if checkRow < 0 || checkRow >= rows || checkCol < 0 || checkCol >= cols {
                        continue
                    }
                    
                    let cellIndex = checkRow * cols + checkCol
                    
                    // Check only particles in this cell
                    for j in spatialGrid[cellIndex] {
                        if i == j { continue }
                        
                        var dx = particles[j].x - particles[i].x
                        var dy = particles[j].y - particles[i].y
                        
                        // Handle screen wrapping
                        if abs(dx) > halfWidth {
                            dx = dx > 0 ? dx - bounds.width : dx + bounds.width
                        }
                        if abs(dy) > halfHeight {
                            dy = dy > 0 ? dy - bounds.height : dy + bounds.height
                        }
                        
                        let distSquared = dx * dx + dy * dy
                        
                        if distSquared > 0 && distSquared < maxDistSquared {
                            let dist = sqrt(distSquared)
                            let normalisedDist = dist / maxDistance
                            
                            let force = calculateForce(
                                distance: normalisedDist,
                                attraction: attractionMatrix[particles[i].type][particles[j].type]
                            )
                            
                            totalForceX += (dx / dist) * force
                            totalForceY += (dy / dist) * force
                        }
                    }
                }
            }
            
            particles[i].vx += totalForceX * forceFactor * dt
            particles[i].vy += totalForceY * forceFactor * dt
            
            particles[i].vx *= frictionFactor
            particles[i].vy *= frictionFactor
        }
        
        // Update positions
        for i in 0..<particles.count {
            particles[i].x += particles[i].vx * dt * 100
            particles[i].y += particles[i].vy * dt * 100
            
            // Wrap around screen edges
            while particles[i].x < 0 { particles[i].x += bounds.width }
            while particles[i].x > bounds.width { particles[i].x -= bounds.width }
            while particles[i].y < 0 { particles[i].y += bounds.height }
            while particles[i].y > bounds.height { particles[i].y -= bounds.height }
        }
    }
    
    private func calculateForce(distance: CGFloat, attraction: CGFloat) -> CGFloat {
        if distance < beta {
            // Short distance: repulsion (prevents sticking)
            return (distance / beta - 1)
        } else if distance < 1 {
            // Medium distance: use attraction value scaled smoothly
            return attraction * (1 - abs(2 * distance - 1 - beta) / (1 - beta))
        } else {
            // Far distance: no force
            return 0
        }
    }
    
    override func draw(_ rect: NSRect) {
        // Black background
        NSColor.black.setFill()
        rect.fill()
        
        // Draw particles
        for particle in particles {
            let color = colors[particle.type]
            color.setFill()
            
            NSBezierPath(ovalIn: NSRect(
                x: particle.x - particleRadius,
                y: particle.y - particleRadius,
                width: particleRadius * 2,
                height: particleRadius * 2
            )).fill()
        }
    }
    
    
    // Cleanup Functions
    @objc func willStop(_ notification: Notification) {
        stopAnimation()
        DistributedNotificationCenter.default.removeObserver(self)
        exit(0)
    }
}
