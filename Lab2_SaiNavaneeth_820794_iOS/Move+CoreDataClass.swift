
import Foundation
import CoreData

@objc(Move)
public class Move: NSManagedObject {

}


extension Move {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Move> {
        return NSFetchRequest<Move>(entityName: "Move")
    }

    @NSManaged public var index: Int32
    @NSManaged public var date: Date?
    @NSManaged public var game_uid: UUID?
    @NSManaged public var player: String?
    @NSManaged public var game: Game?

}
