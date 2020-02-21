
import Foundation
import UIKit
import Firebase

class HomeViewController:UIViewController,
UITableViewDelegate,
UITableViewDataSource {
    
    var cellHeights: [IndexPath : CGFloat] = [:]
    
    @IBOutlet weak var table: UITableView!
    
    var posts = [Post]()
    var fetchingMore = false
    var endReached = false
    let leadingScreensForBatching:CGFloat = 3.0
    
    let model = getTest()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.delegate = self
        table.dataSource = self
        
        view.addVerticalGradientLayer(topColor: secondaryColor , bottomColor: primaryColor)
        beginBatchFetch()
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "post") as? postCell{
            cell.name.text = model.title
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            cell.date.text = formatter.string(from: model.createdAt)
            return cell
        }
       return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toGallery", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toGallery" {
            let controller = (segue.destination as! PreviewViewController)
            controller.matchLog = model
        }
    }
    
    func fetchPosts(completion:@escaping (_ posts:[Post])->()) {
        let postsRef = Database.database().reference().child("posts")
        var queryRef:DatabaseQuery
        let lastPost = posts.last
        if lastPost != nil {
            let lastTimestamp = lastPost!.createdAt.timeIntervalSince1970 * 1000
            queryRef = postsRef.queryOrdered(byChild: "timestamp").queryEnding(atValue: lastTimestamp).queryLimited(toLast: 20)
        } else {
            queryRef = postsRef.queryOrdered(byChild: "timestamp").queryLimited(toLast: 20)
        }
        
        queryRef.observeSingleEvent(of: .value, with: { snapshot in
            var tempPosts = [Post]()
            
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                    let dict = childSnapshot.value as? [String:Any],
                    let author = dict["author"] as? [String:Any],
                    let uid = author["uid"] as? String,
                    let username = author["username"] as? String,
                    let photoURL = author["photoURL"] as? String,
                    let url = URL(string:photoURL),
                    let text = dict["text"] as? String,
                    let timestamp = dict["timestamp"] as? Double {
                    
                    if childSnapshot.key != lastPost?.id {
                        let userProfile = UserProfile(uid: uid, username: username, photoURL: url)
                        let post = Post(id: childSnapshot.key, author: userProfile, text: text, timestamp:timestamp)
                        tempPosts.insert(post, at: 0)
                    }
                    
                }
            }
            
            return completion(tempPosts)
        })
    }
    
    @IBAction func handleLogout(_ sender:Any) {
        try! Auth.auth().signOut()
    }
    
           
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.size.height * leadingScreensForBatching {
            
            if !fetchingMore && !endReached {
                beginBatchFetch()
            }
        }
    }
    
    func beginBatchFetch() {
        fetchingMore = false
         
        fetchPosts { newPosts in
            self.posts.append(contentsOf: newPosts)
            self.fetchingMore = false
            self.endReached = newPosts.count == 0
            UIView.performWithoutAnimation {
            }
        }
    }
}


/*
class main_table_vc: UIViewController {
    
    
    
    
    
    /*
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Secret contacts"
    }*/
    
    
    
    
}
*/

class postCell: UITableViewCell{
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var date: UILabel!
}
