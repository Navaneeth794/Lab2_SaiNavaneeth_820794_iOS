

import Foundation
import CoreData

@objc(Game)
public class Game: NSManagedObject {

}


extension Game {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Game> {
        return NSFetchRequest<Game>(entityName: "Game")
    }

    @NSManaged public var date: Date?
    @NSManaged public var done: Bool
    @NSManaged public var winner: String?
    @NSManaged public var uid: UUID?
    @NSManaged public var moves: NSSet?

}

// MARK: Generated accessors for moves
extension Game {

    @objc(addMovesObject:)
    @NSManaged public func addToMoves(_ value: Move)

    @objc(removeMovesObject:)
    @NSManaged public func removeFromMoves(_ value: Move)

    @objc(addMoves:)
    @NSManaged public func addToMoves(_ values: NSSet)

    @objc(removeMoves:)
    @NSManaged public func removeFromMoves(_ values: NSSet)

}
