import SharedCore
import SpriteKit
import SwiftUI

enum GameSceneFactory {
    static func scene(for game: GameDescriptor) -> SKScene {
        switch game.id {
        case "coconutcatch":
            CoconutCatchScene(size: CGSize(width: 900, height: 700))
        case "turtleflip":
            TurtleFlipScene(game: game, size: CGSize(width: 900, height: 700))
        case "sandsort":
            SandSortScene(game: game, size: CGSize(width: 900, height: 700))
        case "fishduel":
            FishDuelScene(game: game, size: CGSize(width: 900, height: 700))
        case "fruitslicer":
            FruitSlicerScene(game: game, size: CGSize(width: 900, height: 700))
        case "dotconnect":
            DotConnectScene(game: game, size: CGSize(width: 900, height: 700))
        case "wordhunt":
            WordHuntScene(game: game, size: CGSize(width: 900, height: 700))
        case "towerstack":
            TowerStackScene(game: game, size: CGSize(width: 900, height: 700))
        case "starlink":
            StarLinkScene(game: game, size: CGSize(width: 900, height: 700))
        case "pongplus":
            PongPlusScene(game: game, size: CGSize(width: 900, height: 700))
        default:
            MiniArcadeScene(game: game, size: CGSize(width: 900, height: 700))
        }
    }
}

final class CoconutCatchScene: SKScene {
    private let basket = SKShapeNode(rectOf: CGSize(width: 130, height: 34), cornerRadius: 12)
    private var lastSpawn: TimeInterval = 0
    private var score = 0
    private let scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")

    override func didMove(to view: SKView) {
        backgroundColor = UIColor(red: 0.30, green: 0.71, blue: 0.89, alpha: 1)
        basket.fillColor = UIColor(red: 1.0, green: 0.54, blue: 0.40, alpha: 1)
        basket.strokeColor = .white
        basket.position = CGPoint(x: size.width / 2, y: 74)
        addChild(basket)

        scoreLabel.text = "Score 0"
        scoreLabel.fontSize = 34
        scoreLabel.fontColor = .white
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 28, y: size.height - 62)
        addChild(scoreLabel)

        let title = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        title.text = "Coconut Catch"
        title.fontSize = 38
        title.fontColor = UIColor(red: 0.12, green: 0.18, blue: 0.22, alpha: 1)
        title.position = CGPoint(x: size.width / 2, y: size.height - 64)
        addChild(title)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        basket.position.x = max(70, min(size.width - 70, location.x))
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesMoved(touches, with: event)
    }

    override func update(_ currentTime: TimeInterval) {
        if currentTime - lastSpawn > 0.78 {
            spawnDrop()
            lastSpawn = currentTime
        }
        for node in children where node.name == "drop" {
            if node.position.y < 42 {
                node.removeFromParent()
            } else if abs(node.position.x - basket.position.x) < 76 && abs(node.position.y - basket.position.y) < 42 {
                score += node.userData?["hazard"] as? Bool == true ? -25 : 10
                score = max(0, score)
                scoreLabel.text = "Score \(score)"
                node.removeFromParent()
            }
        }
    }

    private func spawnDrop() {
        let hazard = Int.random(in: 0...7) == 0
        let node = SKShapeNode(circleOfRadius: hazard ? 20 : 24)
        node.name = "drop"
        node.fillColor = hazard ? .darkGray : UIColor(red: 0.42, green: 0.25, blue: 0.11, alpha: 1)
        node.strokeColor = .white
        let metadata = NSMutableDictionary()
        metadata["hazard"] = hazard
        node.userData = metadata
        node.position = CGPoint(x: CGFloat.random(in: 50...(size.width - 50)), y: size.height + 40)
        addChild(node)
        node.run(.moveBy(x: 0, y: -size.height - 120, duration: hazard ? 3.2 : 4.2))
    }
}

class MiniArcadeScene: SKScene {
    let game: GameDescriptor
    let scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    let instructionLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
    var score = 0

    init(game: GameDescriptor, size: CGSize) {
        self.game = game
        super.init(size: size)
        scaleMode = .resizeFill
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        backgroundColor = UIColor(red: 0.96, green: 0.88, blue: 0.76, alpha: 1)
        buildChrome(instruction: game.controls)
        setupGame()
    }

    func setupGame() {
        for index in 0..<8 {
            let node = SKShapeNode(circleOfRadius: CGFloat(20 + index * 4))
            node.fillColor = UIColor(red: CGFloat.random(in: 0.25...0.95), green: CGFloat.random(in: 0.45...0.85), blue: CGFloat.random(in: 0.55...0.95), alpha: 0.82)
            node.strokeColor = .white
            node.position = CGPoint(x: CGFloat.random(in: 80...(size.width - 80)), y: CGFloat.random(in: 160...(size.height - 190)))
            addChild(node)
        }
    }

    func buildChrome(instruction: String) {
        let title = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        title.text = game.localizedTitle
        title.fontColor = UIColor(red: 0.12, green: 0.18, blue: 0.22, alpha: 1)
        title.fontSize = 44
        title.position = CGPoint(x: size.width / 2, y: size.height - 92)
        addChild(title)

        instructionLabel.text = instruction
        instructionLabel.fontColor = UIColor(red: 0.18, green: 0.31, blue: 0.38, alpha: 1)
        instructionLabel.fontSize = 24
        instructionLabel.position = CGPoint(x: size.width / 2, y: size.height - 136)
        addChild(instructionLabel)

        scoreLabel.text = "Score 0"
        scoreLabel.fontColor = UIColor(red: 1.0, green: 0.54, blue: 0.40, alpha: 1)
        scoreLabel.fontSize = 28
        scoreLabel.position = CGPoint(x: size.width / 2, y: 62)
        addChild(scoreLabel)
    }

    func updateScore(prefix: String = "Score") {
        score = max(0, score)
        scoreLabel.text = "\(prefix) \(score)"
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        score += 10
        updateScore()
    }
}

final class TurtleFlipScene: MiniArcadeScene {}
final class SandSortScene: MiniArcadeScene {}

final class FishDuelScene: MiniArcadeScene {
    private let fish = SKShapeNode(ellipseOf: CGSize(width: 96, height: 42))
    private let hook = SKShapeNode(circleOfRadius: 12)

    override func setupGame() {
        instructionLabel.text = "等魚游到釣線下方再點擊"
        fish.fillColor = UIColor(red: 0.18, green: 0.55, blue: 0.86, alpha: 1)
        fish.strokeColor = .white
        fish.position = CGPoint(x: 100, y: size.height * 0.48)
        addChild(fish)
        fish.run(.repeatForever(.sequence([.moveTo(x: size.width - 100, duration: 1.6), .moveTo(x: 100, duration: 1.6)])))

        let line = SKShapeNode(rectOf: CGSize(width: 4, height: size.height * 0.38), cornerRadius: 2)
        line.fillColor = .white
        line.strokeColor = .white
        line.position = CGPoint(x: size.width / 2, y: size.height * 0.64)
        addChild(line)

        hook.fillColor = UIColor(red: 1.0, green: 0.54, blue: 0.40, alpha: 1)
        hook.strokeColor = .white
        hook.position = CGPoint(x: size.width / 2, y: size.height * 0.45)
        addChild(hook)
        updateScore(prefix: "釣獲")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let distance = abs(fish.position.x - hook.position.x)
        score += distance < 34 ? 120 : (distance < 86 ? 45 : -20)
        updateScore(prefix: "釣獲")
        fish.run(.sequence([.scale(to: 1.22, duration: 0.08), .scale(to: 1, duration: 0.12)]))
    }
}

final class FruitSlicerScene: MiniArcadeScene {
    private var lastSpawn: TimeInterval = 0

    override func setupGame() {
        instructionLabel.text = "滑過水果加分，避開黑色陷阱"
        updateScore(prefix: "切片")
    }

    override func update(_ currentTime: TimeInterval) {
        if currentTime - lastSpawn > 0.72 {
            spawnFruit()
            lastSpawn = currentTime
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        slice(touches)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        slice(touches)
    }

    private func spawnFruit() {
        let hazard = Int.random(in: 0...8) == 0
        let fruit = SKShapeNode(circleOfRadius: hazard ? 24 : CGFloat.random(in: 20...32))
        fruit.name = "fruit"
        fruit.userData = ["hazard": hazard]
        fruit.fillColor = hazard ? .black : [UIColor.systemPink, .systemOrange, .systemYellow, .systemGreen].randomElement()!
        fruit.strokeColor = .white
        fruit.position = CGPoint(x: CGFloat.random(in: 80...(size.width - 80)), y: -40)
        addChild(fruit)
        fruit.run(.sequence([
            .group([.moveBy(x: CGFloat.random(in: -100...100), y: size.height + 160, duration: Double.random(in: 1.7...2.5)), .rotate(byAngle: 5.5, duration: 2.0)]),
            .removeFromParent()
        ]))
    }

    private func slice(_ touches: Set<UITouch>) {
        guard let point = touches.first?.location(in: self) else { return }
        for node in nodes(at: point) where node.name == "fruit" {
            let hazard = node.userData?["hazard"] as? Bool == true
            score += hazard ? -50 : 15
            updateScore(prefix: "切片")
            node.removeFromParent()
        }
    }
}

final class DotConnectScene: MiniArcadeScene {
    private var points: [CGPoint] = []
    private var selectedIndex: Int?
    private var edges = Set<String>()
    private let grid = 4

    override func setupGame() {
        instructionLabel.text = "點相鄰格點連線，圍成方格得分"
        let spacing: CGFloat = 120
        let start = CGPoint(x: size.width / 2 - spacing * 1.5, y: size.height / 2 - spacing)
        for row in 0..<grid {
            for column in 0..<grid {
                let point = CGPoint(x: start.x + CGFloat(column) * spacing, y: start.y + CGFloat(row) * spacing)
                points.append(point)
                let dot = SKShapeNode(circleOfRadius: 10)
                dot.fillColor = UIColor(red: 0.18, green: 0.31, blue: 0.38, alpha: 1)
                dot.strokeColor = .white
                dot.position = point
                addChild(dot)
            }
        }
        updateScore(prefix: "方格")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self), let index = nearestPoint(to: location) else { return }
        if let selectedIndex, isAdjacent(selectedIndex, index) {
            addEdge(from: selectedIndex, to: index)
            self.selectedIndex = nil
        } else {
            selectedIndex = index
        }
    }

    private func nearestPoint(to location: CGPoint) -> Int? {
        points.enumerated().min(by: { distance($0.element, location) < distance($1.element, location) }).flatMap {
            distance($0.element, location) < 48 ? $0.offset : nil
        }
    }

    private func isAdjacent(_ first: Int, _ second: Int) -> Bool {
        let a = (row: first / grid, col: first % grid)
        let b = (row: second / grid, col: second % grid)
        return abs(a.row - b.row) + abs(a.col - b.col) == 1
    }

    private func addEdge(from first: Int, to second: Int) {
        let key = edgeKey(first, second)
        guard !edges.contains(key) else { return }
        edges.insert(key)

        let path = CGMutablePath()
        path.move(to: points[first])
        path.addLine(to: points[second])
        let line = SKShapeNode(path: path)
        line.lineWidth = 9
        line.strokeColor = UIColor(red: 1.0, green: 0.54, blue: 0.40, alpha: 1)
        addChild(line)

        score += completedSquareCount() * 40 + 5
        updateScore(prefix: "方格")
    }

    private func completedSquareCount() -> Int {
        var completed = 0
        for row in 0..<(grid - 1) {
            for col in 0..<(grid - 1) {
                let topLeft = row * grid + col
                let squareEdges = [
                    edgeKey(topLeft, topLeft + 1),
                    edgeKey(topLeft, topLeft + grid),
                    edgeKey(topLeft + 1, topLeft + grid + 1),
                    edgeKey(topLeft + grid, topLeft + grid + 1)
                ]
                if squareEdges.allSatisfy(edges.contains) {
                    completed += 1
                }
            }
        }
        return completed
    }
}

final class WordHuntScene: MiniArcadeScene {
    private let letters = Array("ISLESTARFISHSAND")
    private let words: Set<String> = ["ISLE", "STAR", "FISH", "SAND"]
    private var selectedLetters: [String] = []
    private var selectedNodes: [SKShapeNode] = []

    override func setupGame() {
        instructionLabel.text = "滑動連出 ISLE、STAR、FISH、SAND"
        let cell: CGFloat = 92
        let start = CGPoint(x: size.width / 2 - cell * 1.5, y: size.height / 2 - cell * 1.2)
        for row in 0..<4 {
            for col in 0..<4 {
                let index = row * 4 + col
                let tile = SKShapeNode(rectOf: CGSize(width: 72, height: 72), cornerRadius: 12)
                tile.name = "letter"
                tile.userData = ["letter": String(letters[index])]
                tile.fillColor = .white
                tile.strokeColor = UIColor(red: 0.18, green: 0.31, blue: 0.38, alpha: 1)
                tile.position = CGPoint(x: start.x + CGFloat(col) * cell, y: start.y + CGFloat(row) * cell)
                addChild(tile)

                let label = SKLabelNode(fontNamed: "AvenirNext-Heavy")
                label.text = String(letters[index])
                label.fontSize = 34
                label.fontColor = UIColor(red: 0.18, green: 0.31, blue: 0.38, alpha: 1)
                label.verticalAlignmentMode = .center
                tile.addChild(label)
            }
        }
        updateScore(prefix: "單字")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        resetSelection()
        collect(touches)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        collect(touches)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let word = selectedLetters.joined()
        if words.contains(word) {
            score += word.count * 25
            updateScore(prefix: "單字")
        }
        resetSelection()
    }

    private func collect(_ touches: Set<UITouch>) {
        guard let point = touches.first?.location(in: self),
              let node = nodes(at: point).compactMap({ $0 as? SKShapeNode }).first(where: { $0.name == "letter" }),
              !selectedNodes.contains(where: { $0 === node }),
              let letter = node.userData?["letter"] as? String else { return }
        selectedNodes.append(node)
        selectedLetters.append(letter)
        node.fillColor = UIColor(red: 1.0, green: 0.84, blue: 0.35, alpha: 1)
    }

    private func resetSelection() {
        selectedNodes.forEach { $0.fillColor = .white }
        selectedNodes.removeAll()
        selectedLetters.removeAll()
    }
}

final class TowerStackScene: MiniArcadeScene {
    private var towerTopY: CGFloat = 150
    private var currentWidth: CGFloat = 210
    private var movingBlock: SKShapeNode?

    override func setupGame() {
        instructionLabel.text = "點擊落下積木，越對齊越高分"
        let base = block(width: currentWidth, color: UIColor(red: 0.18, green: 0.31, blue: 0.38, alpha: 1))
        base.position = CGPoint(x: size.width / 2, y: towerTopY)
        addChild(base)
        updateScore(prefix: "高度")
        spawnMovingBlock()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let block = movingBlock else { return }
        block.removeAllActions()
        let overlap = currentWidth - abs(block.position.x - size.width / 2)
        if overlap < 42 {
            score = 0
            currentWidth = 210
            towerTopY = 150
            removeChildren(in: children.filter { $0.name == "tower" })
        } else {
            currentWidth = min(230, max(64, overlap + 10))
            towerTopY += 38
            score += 1
        }
        updateScore(prefix: "高度")
        spawnMovingBlock()
    }

    private func spawnMovingBlock() {
        let block = block(width: currentWidth, color: UIColor(red: 1.0, green: 0.54, blue: 0.40, alpha: 1))
        block.position = CGPoint(x: 90, y: min(towerTopY + 50, size.height - 190))
        addChild(block)
        block.run(.repeatForever(.sequence([.moveTo(x: size.width - 90, duration: 1.2), .moveTo(x: 90, duration: 1.2)])))
        movingBlock = block
    }

    private func block(width: CGFloat, color: UIColor) -> SKShapeNode {
        let node = SKShapeNode(rectOf: CGSize(width: width, height: 34), cornerRadius: 8)
        node.name = "tower"
        node.fillColor = color
        node.strokeColor = .white
        return node
    }
}

final class StarLinkScene: MiniArcadeScene {
    private var activeNode: SKShapeNode?

    override func setupGame() {
        instructionLabel.text = "拖曳連起相同顏色星點"
        let colors: [UIColor] = [.systemPink, .systemTeal, .systemYellow, .systemPurple]
        for (index, color) in (colors + colors).shuffled().enumerated() {
            let node = SKShapeNode(circleOfRadius: 28)
            node.name = "star"
            node.userData = ["pair": "\(index % 4)"]
            node.fillColor = color
            node.strokeColor = .white
            node.position = CGPoint(x: 180 + CGFloat(index % 4) * 170, y: 240 + CGFloat(index / 4) * 170)
            addChild(node)
        }
        updateScore(prefix: "星線")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }
        activeNode = nodes(at: point).compactMap { $0 as? SKShapeNode }.first { $0.name == "star" }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let start = activeNode,
              let point = touches.first?.location(in: self),
              let end = nodes(at: point).compactMap({ $0 as? SKShapeNode }).first(where: { $0.name == "star" && $0 !== start }),
              start.fillColor == end.fillColor else {
            activeNode = nil
            return
        }
        let path = CGMutablePath()
        path.move(to: start.position)
        path.addLine(to: end.position)
        let line = SKShapeNode(path: path)
        line.lineWidth = 10
        line.strokeColor = start.fillColor
        addChild(line)
        score += 50
        updateScore(prefix: "星線")
        activeNode = nil
    }
}

final class PongPlusScene: MiniArcadeScene {
    private let player = SKShapeNode(rectOf: CGSize(width: 150, height: 26), cornerRadius: 12)
    private let opponent = SKShapeNode(rectOf: CGSize(width: 150, height: 26), cornerRadius: 12)
    private let ball = SKShapeNode(circleOfRadius: 18)
    private var velocity = CGVector(dx: 5.5, dy: 5.0)

    override func setupGame() {
        instructionLabel.text = "滑動下方球拍反彈特殊球"
        player.fillColor = UIColor(red: 1.0, green: 0.54, blue: 0.40, alpha: 1)
        opponent.fillColor = UIColor(red: 0.18, green: 0.31, blue: 0.38, alpha: 1)
        ball.fillColor = .white
        [player, opponent, ball].forEach {
            $0.strokeColor = .white
            addChild($0)
        }
        player.position = CGPoint(x: size.width / 2, y: 116)
        opponent.position = CGPoint(x: size.width / 2, y: size.height - 190)
        ball.position = CGPoint(x: size.width / 2, y: size.height / 2)
        updateScore(prefix: "回合")
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }
        player.position.x = max(90, min(size.width - 90, point.x))
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesMoved(touches, with: event)
    }

    override func update(_ currentTime: TimeInterval) {
        ball.position.x += velocity.dx
        ball.position.y += velocity.dy
        opponent.position.x += (ball.position.x - opponent.position.x) * 0.055

        if ball.position.x < 28 || ball.position.x > size.width - 28 {
            velocity.dx *= -1
        }
        if intersectsPaddle(player), velocity.dy < 0 {
            velocity.dy = abs(velocity.dy) + 0.25
            score += 10
            updateScore(prefix: "回合")
        }
        if intersectsPaddle(opponent), velocity.dy > 0 {
            velocity.dy = -abs(velocity.dy)
        }
        if ball.position.y < 70 || ball.position.y > size.height - 120 {
            ball.position = CGPoint(x: size.width / 2, y: size.height / 2)
            velocity = CGVector(dx: CGFloat.random(in: -5.8...5.8), dy: 5.0)
        }
    }

    private func intersectsPaddle(_ paddle: SKShapeNode) -> Bool {
        abs(ball.position.x - paddle.position.x) < 92 && abs(ball.position.y - paddle.position.y) < 32
    }
}

private func distance(_ first: CGPoint, _ second: CGPoint) -> CGFloat {
    hypot(first.x - second.x, first.y - second.y)
}

private func edgeKey(_ first: Int, _ second: Int) -> String {
    let low = min(first, second)
    let high = max(first, second)
    return "\(low)-\(high)"
}
