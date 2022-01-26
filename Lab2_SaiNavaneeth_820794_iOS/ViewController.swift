
import UIKit
import CoreData

class ViewController: UIViewController {
    
    
    @IBOutlet weak var labelX: UILabel!
    @IBOutlet weak var labelO: UILabel!
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet var swipeView: UIView!
    
    var currentPlayer = "X"
    
    var x = 0
    var o = 0
    
    var rules = [[0,1,2],[3,4,5],[6,7,8],[1,4,7],[2,5,8],[0,4,8],[2,4,6],[0,3,6]]
    
    var board = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        becomeFirstResponder()
        
        self.view.addGestureRecognizer(leftSwipeGestureRecognizer)
        self.view.addGestureRecognizer(rightSwipeGestureRecognizer)
        loadBoard()
        
        loadGame()
        loadScore()
        resumeGame()
        updateScore()
        
        print(board)
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        print("motion Began")
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        print("motion Ended")
        if motion == .motionShake {
            let alert = UIAlertController(title: "Undo previous move ?", message: nil, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [weak self] _ in
                
                self?.undoLastMove()
                
            }))
            present(alert, animated: true)
        }
    }
    
    @objc func swipedLeft(sender: UISwipeGestureRecognizer) {
        if sender.state == .ended {
            reset()
            print("Swiped left")
        }
    }
    
    @objc func swipedRight(sender: UISwipeGestureRecognizer) {
        if sender.state == .ended {
            reset()
            print("Swiped right")
        }
    }
    
    lazy var leftSwipeGestureRecognizer: UISwipeGestureRecognizer = {
        let gesture = UISwipeGestureRecognizer()
        gesture.direction = .left
        gesture.addTarget(self, action: #selector(swipedLeft))
        return gesture
    }()
    
    lazy var rightSwipeGestureRecognizer: UISwipeGestureRecognizer = {
        let gesture = UISwipeGestureRecognizer()
        gesture.direction = .right
        gesture.addTarget(self, action: #selector(swipedRight))
        return gesture
    }()
    
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        let index = buttons.firstIndex(of: 	sender)!
        print(index)
        updateButtons(index: index, player: self.currentPlayer)
        whoWins()
    }
    
    func updateButtons(index: Int, player: String) {
        if !board[index].isEmpty {return}
        let context = appDelegate.persistentContainer.viewContext
        let cp = player
        
        if currentGame == nil {
            currentGame = Game(context: context)
            currentGame?.date =  Date()
            currentGame?.done = false
            currentGame?.uid = UUID()
        }
        let move = Move(context: context)
        move.index = Int32(index)
        move.player = cp
        move.date = Date()
        move.game_uid = currentGame?.uid
        moves.append(move)
        saveGame(context: context)
        
        if(player == "X"){
            buttons[index].setTitle("X", for: .normal)
            currentPlayer = "O"
            board[index] = "X"
        }else{
            buttons[index].setTitle("O", for: .normal)
            currentPlayer = "X"
            board[index] = "O"
        }
        
        
    }
    
    func undoButtons(index: Int, player: String) {
        board[index] = ""
        buttons[index].setTitle("", for: .normal)
        currentPlayer = player
        
    }
    
    func whoWins(){
        let context = appDelegate.persistentContainer.viewContext
        for rule in rules {
            let player1 = board[rule[0]]
            let player2 = board[rule[1]]
            let player3 = board[rule[2]]
            
            if player1 == player2,
                player2 == player3,
                !player1.isEmpty {
                print ("winner is \(player2)")
                showAlert(msg: "Player \(player3) You've won!")
                
                if player1 == "X" {
                    x=x+1
                    labelX.text = String(x);
                }else{
                    o=o+1
                    labelO.text = String(o);
                }
                
                currentGame?.done = true
                currentGame?.winner = player3
                saveGame(context: context)
                updateScore()
                loadScore()
                return
            }
        }
        if !board.contains(""){
            showAlert(msg: "It's a Draw!")
            currentGame?.done = true
            currentGame?.winner = "Draw"
            saveGame(context: context)
        }
    }
    
    func showAlert(msg: String) {
        let alert  = UIAlertController(title: "Success",message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) {
            _ in self.reset()
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func reset() {
        let context = appDelegate.persistentContainer.viewContext
        board.removeAll()
        loadBoard()
        for m in moves {
            context.delete(m)
        }
        for button in buttons {
            button.setTitle(nil, for: .normal)
        }
        saveGame(context: context)
        moves = [Move]()
    }
    
    func loadBoard(){
        for i in 0..<buttons.count {
            board.append("")
        }
    }
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var games = [Game]()
    func loadGame() {
        let context = appDelegate.persistentContainer.viewContext
        let request = Game.fetchRequest() as! NSFetchRequest
        var predicate: NSPredicate = NSPredicate()
        predicate = NSPredicate(format: "done = '\(false)'")
        request.predicate = predicate
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        do {
            games = try context.fetch(request)
            updateMoves()
        }
        catch {
            print("Fetch Failed")
        }
    }
    
    var scores = [Score]()
    func loadScore() {
        let context = appDelegate.persistentContainer.viewContext
        let request = Score.fetchRequest() as! NSFetchRequest
        do {
            scores = try context.fetch(request)
            if scores.count == 0 {
                let players = ["X", "O"]
                for p in players {
                    let score = Score(context: context)
                    score.player = p
                    score.score = Int32(Int(0))
                    do {
                        try! context.save()
                    } catch  {
                    }
                }
                loadScore()
                return
            }
            
            for s in scores {
                if s.player == "X"
                {x = Int(s.score)
                    labelX.text = String(x)
                }
                else {o = Int(s.score)
                    labelO.text = String(o)
                }
            }
        }
        catch {
            print("Fetch Failed")
        }
    }
    
    var moves = [Move]()
    var currentGame : Game? = nil
    func updateMoves() {
        if( games.count > 0 ){
            var game: Game? = nil
            for g in games {
                if g.done == false {
                    game = g
                    currentGame = g
                }
            }
            if game != nil {
                let moves = game?.moves
                if moves != nil && moves!.count > 0{
                    
                    let set = moves as! NSMutableSet
                    let array = set.allObjects  as! [Move];
                    let sortedMoves = array.sorted(by: { (m1: Move, m2: Move) -> Bool in
                        return m1.date! > m2.date!
                    })
                    self.moves = sortedMoves
                }
            }
        }
    }
    
    var loading = true
    func resumeGame() {
        for m in moves.reversed() {
            updateButtons(index: Int(m.index), player: m.player!)
            print(m.date)
        }
        moves.reversed()
        loading = false
    }
    
    func saveGame(context: NSManagedObjectContext) {
        //        let context = appDelegate.persistentContainer.viewContext
        if(loading == true ) {return}
        let moves2 =  NSSet(array: self.moves)
        currentGame?.addToMoves(moves2)
        print(moves2.count)
        do {
            try! context.save()
        }
        catch {
        }
    }
    
    func updateScore() {
        let context = appDelegate.persistentContainer.viewContext
        for p in scores {
            if(p.player == currentPlayer)
            {
                p.score = p.score + 1
                do {
                    try! context.save()
                } catch  {
                }}
        }
    }
    
    func undoLastMove(){
        let context = appDelegate.persistentContainer.viewContext
        updateMoves()
        if moves.count > 0 {
            let sortedMoves = moves.sorted(by: { (m1: Move, m2: Move) -> Bool in
                return m1.date! > m2.date!
            })
            moves = sortedMoves
            undoButtons(index: Int(moves[moves.startIndex].index), player: moves[moves.startIndex].player ?? "" )
            
            print(moves.count)
            context.delete(moves[moves.startIndex])
            
            saveGame(context: context)
            moves.remove(at:  moves.startIndex)
            print(moves.count)
        }
        
        
    }
}

