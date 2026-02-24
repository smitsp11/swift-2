import Foundation

/// The Rangoli lattice — a graph of dot positions and edges for Eulerian path drawing.
/// After the burst phase (30 beats), the drawing engine transitions to tracing paths
/// through this lattice using Hierholzer's algorithm.
struct RangoliLattice {
    /// A single edge in the lattice graph
    struct Edge {
        let fromAngle: Double
        let fromRadius: Double
        let toAngle: Double
        let toRadius: Double
    }

    /// Node position in polar coordinates
    struct Node: Hashable {
        let index: Int
        let x: Double  // Cartesian x (relative to center)
        let y: Double  // Cartesian y (relative to center)

        var angle: Double { atan2(y, x) }
        var radius: Double { sqrt(x * x + y * y) }

        func hash(into hasher: inout Hasher) {
            hasher.combine(index)
        }

        static func == (lhs: Node, rhs: Node) -> Bool {
            lhs.index == rhs.index
        }
    }

    private var nodes: [Node] = []
    private var adjacency: [[Int]] = []  // adjacency list
    private var eulerianPath: [Int] = []
    private var pathIndex: Int = 0

    init(night: Night) {
        buildNodes(night: night)
        buildEdges(night: night)
        computeEulerianPath()
    }

    /// Get the next edge in the Eulerian traversal. Returns nil if exhausted.
    mutating func nextEdge() -> Edge? {
        guard pathIndex + 1 < eulerianPath.count else {
            // Restart the path for infinite drawing
            pathIndex = 0
            guard pathIndex + 1 < eulerianPath.count else { return nil }
            return nil  // Skip one beat on restart for visual pause
        }

        let fromIdx = eulerianPath[pathIndex]
        let toIdx = eulerianPath[pathIndex + 1]
        pathIndex += 1

        let from = nodes[fromIdx]
        let to = nodes[toIdx]

        return Edge(
            fromAngle: from.angle,
            fromRadius: from.radius,
            toAngle: to.angle,
            toRadius: to.radius
        )
    }

    /// Reset traversal to beginning
    mutating func reset() {
        pathIndex = 0
    }

    /// Get all dot positions for rendering the lattice grid
    var dotPositions: [CGPoint] {
        nodes.map { CGPoint(x: $0.x, y: $0.y) }
    }

    // MARK: - Build Graph

    private mutating func buildNodes(night: Night) {
        nodes.removeAll()
        let size = night.latticeSize
        let spacing: Double = 28.0  // Points between grid nodes

        if night.isRadialLattice {
            // Radial lattice: concentric rings of dots
            var idx = 0
            // Center node
            nodes.append(Node(index: idx, x: 0, y: 0))
            idx += 1

            let rings = size / 2
            for ring in 1...rings {
                let radius = Double(ring) * spacing
                let nodesInRing = max(6, ring * 6)  // More nodes in outer rings
                for j in 0..<nodesInRing {
                    let angle = (2 * .pi / Double(nodesInRing)) * Double(j)
                    let x = radius * cos(angle)
                    let y = radius * sin(angle)
                    nodes.append(Node(index: idx, x: x, y: y))
                    idx += 1
                }
            }
        } else {
            // Square lattice: N×N grid centered at origin
            var idx = 0
            let halfSize = Double(size - 1) / 2.0
            for row in 0..<size {
                for col in 0..<size {
                    let x = (Double(col) - halfSize) * spacing
                    let y = (Double(row) - halfSize) * spacing
                    nodes.append(Node(index: idx, x: x, y: y))
                    idx += 1
                }
            }
        }
    }

    private mutating func buildEdges(night: Night) {
        let n = nodes.count
        adjacency = Array(repeating: [], count: n)

        if night.isRadialLattice {
            // Connect each node to nearby nodes (within distance threshold)
            let maxDist = 35.0  // Connect nodes within this distance
            for i in 0..<n {
                for j in (i + 1)..<n {
                    let dx = nodes[i].x - nodes[j].x
                    let dy = nodes[i].y - nodes[j].y
                    let dist = sqrt(dx * dx + dy * dy)
                    if dist < maxDist {
                        adjacency[i].append(j)
                        adjacency[j].append(i)
                    }
                }
            }
        } else {
            // Square grid: connect to 4-neighbors
            let size = night.latticeSize
            for row in 0..<size {
                for col in 0..<size {
                    let idx = row * size + col
                    // Right neighbor
                    if col + 1 < size {
                        let right = row * size + (col + 1)
                        adjacency[idx].append(right)
                        adjacency[right].append(idx)
                    }
                    // Bottom neighbor
                    if row + 1 < size {
                        let below = (row + 1) * size + col
                        adjacency[idx].append(below)
                        adjacency[below].append(idx)
                    }
                }
            }
        }

        // Ensure all nodes have even degree for Eulerian circuit
        ensureEvenDegrees()
    }

    /// Make all vertices have even degree by adding/removing edges
    private mutating func ensureEvenDegrees() {
        var oddVertices: [Int] = []
        for i in 0..<adjacency.count {
            if adjacency[i].count % 2 != 0 {
                oddVertices.append(i)
            }
        }

        // Pair up odd-degree vertices and add edges between them
        var i = 0
        while i + 1 < oddVertices.count {
            let a = oddVertices[i]
            let b = oddVertices[i + 1]
            adjacency[a].append(b)
            adjacency[b].append(a)
            i += 2
        }
    }

    /// Compute Eulerian circuit using Hierholzer's algorithm
    private mutating func computeEulerianPath() {
        guard !nodes.isEmpty else { return }

        // Work with a mutable copy of adjacency
        var adjCopy = adjacency.map { Array($0) }
        var stack: [Int] = [0]
        var circuit: [Int] = []

        while !stack.isEmpty {
            let v = stack.last!
            if adjCopy[v].isEmpty {
                circuit.append(v)
                stack.removeLast()
            } else {
                let u = adjCopy[v].removeLast()
                // Remove reverse edge
                if let idx = adjCopy[u].firstIndex(of: v) {
                    adjCopy[u].remove(at: idx)
                }
                stack.append(u)
            }
        }

        eulerianPath = circuit.reversed()

        // If path is too short, create a simple traversal through all nodes
        if eulerianPath.count < nodes.count / 2 {
            eulerianPath = Array(0..<nodes.count) + [0]
        }
    }
}
