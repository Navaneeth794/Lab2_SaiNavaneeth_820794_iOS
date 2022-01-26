
import Foundation
import CoreData

@objc(Score)
public class Score: NSManagedObject {

}
extension Score {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Score> {
        return NSFetchRequest<Score>(entityName: "Score")
    }

    @NSManaged public var player: String?
    @NSManaged public var score: Int32

}
