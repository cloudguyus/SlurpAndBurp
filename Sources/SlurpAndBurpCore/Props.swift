import Foundation

public enum PropKind: String, Codable, CaseIterable, Sendable {
    case grape, cookie, napkin, plate, cupcake, sandwich, thermos, cooler, basket
    case spoon, spatula, mug, kettle, toaster, pot, chair, table, fridge
    case ball, frisbee, gnome, wateringCan, planter, grill, bike, doghouse
    case cone, hydrant, trashCan, bench, car, tree, kiosk, building

    public var displayName: String {
        switch self {
        case .grape: return "Grape"
        case .cookie: return "Cookie"
        case .napkin: return "Napkin"
        case .plate: return "Plate"
        case .cupcake: return "Cupcake"
        case .sandwich: return "Sandwich"
        case .thermos: return "Thermos"
        case .cooler: return "Cooler"
        case .basket: return "Basket"
        case .spoon: return "Spoon"
        case .spatula: return "Spatula"
        case .mug: return "Mug"
        case .kettle: return "Kettle"
        case .toaster: return "Toaster"
        case .pot: return "Pot"
        case .chair: return "Chair"
        case .table: return "Table"
        case .fridge: return "Fridge"
        case .ball: return "Ball"
        case .frisbee: return "Frisbee"
        case .gnome: return "Gnome"
        case .wateringCan: return "Watering Can"
        case .planter: return "Planter"
        case .grill: return "Grill"
        case .bike: return "Bike"
        case .doghouse: return "Doghouse"
        case .cone: return "Cone"
        case .hydrant: return "Hydrant"
        case .trashCan: return "Trash Can"
        case .bench: return "Bench"
        case .car: return "Car"
        case .tree: return "Tree"
        case .kiosk: return "Kiosk"
        case .building: return "Building"
        }
    }

    /// Horizontal footprint. The hole has to grow past this before the prop tips in.
    public var radius: Float {
        switch self {
        case .grape: return 0.22
        case .cookie: return 0.36
        case .napkin: return 0.30
        case .plate: return 0.46
        case .cupcake: return 0.62
        case .sandwich: return 0.78
        case .thermos: return 0.96
        case .cooler: return 1.28
        case .basket: return 1.58
        case .spoon: return 0.24
        case .spatula: return 0.34
        case .mug: return 0.50
        case .kettle: return 0.74
        case .toaster: return 0.98
        case .pot: return 1.18
        case .chair: return 1.38
        case .table: return 2.1
        case .fridge: return 2.6
        case .ball: return 0.26
        case .frisbee: return 0.38
        case .gnome: return 0.56
        case .wateringCan: return 0.76
        case .planter: return 0.98
        case .grill: return 1.38
        case .bike: return 1.8
        case .doghouse: return 2.4
        case .cone: return 0.28
        case .hydrant: return 0.42
        case .trashCan: return 0.56
        case .bench: return 1.08
        case .car: return 1.58
        case .tree: return 2.1
        case .kiosk: return 2.75
        case .building: return 3.55
        }
    }

    /// Approximate height, used so props sit on the ground and sink out of sight.
    public var height: Float {
        switch self {
        case .grape: return 0.4
        case .cookie: return 0.22
        case .napkin: return 0.08
        case .plate: return 0.1
        case .cupcake: return 0.55
        case .sandwich: return 0.4
        case .thermos: return 0.9
        case .cooler: return 0.85
        case .basket: return 0.7
        case .spoon: return 0.16
        case .spatula: return 0.12
        case .mug: return 0.5
        case .kettle: return 0.7
        case .toaster: return 0.55
        case .pot: return 0.6
        case .chair: return 1.0
        case .table: return 0.9
        case .fridge: return 2.2
        case .ball: return 0.5
        case .frisbee: return 0.1
        case .gnome: return 0.9
        case .wateringCan: return 0.7
        case .planter: return 0.7
        case .grill: return 1.0
        case .bike: return 1.1
        case .doghouse: return 1.5
        case .cone: return 0.7
        case .hydrant: return 0.7
        case .trashCan: return 0.8
        case .bench: return 0.7
        case .car: return 0.7
        case .tree: return 2.4
        case .kiosk: return 1.8
        case .building: return 3.2
        }
    }
}

public struct PropSpawn: Equatable, Identifiable, Sendable {
    public let id: Int
    public let kind: PropKind
    public var position: Vec2
    public var yaw: Float
    public let radius: Float
    public let height: Float
    public let mass: Float
    public let score: Int

    public init(
        id: Int,
        kind: PropKind,
        position: Vec2,
        yaw: Float,
        radius: Float,
        height: Float,
        mass: Float,
        score: Int
    ) {
        self.id = id
        self.kind = kind
        self.position = position
        self.yaw = yaw
        self.radius = radius
        self.height = height
        self.mass = mass
        self.score = score
    }
}
