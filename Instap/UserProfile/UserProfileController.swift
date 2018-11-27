//
//  UserProfileController.swift
//  Instap
//
//  Created by Sherif Kamal on 8/19/18.
//  Copyright © 2018 Sherif Kamal. All rights reserved.
//

import UIKit
import Firebase

class UserProfileController: HomePostCellViewController {
    
    var user: User? {
        didSet {
            configureUser()
        }
    }
    
    private var header: UserProfileHeader?
    
    private let alertController: UIAlertController = {
        let ac = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        return ac
    }()
    
//    private var isFinishedPaging = false
//    private var pagingCount: Int = 4
    
    private var isGridView: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = .black
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleRefresh), name: NSNotification.Name.updateUserProfileFeed, object: nil)
        
        collectionView?.backgroundColor = .white
        collectionView?.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: UserProfileHeader.headerId)
        collectionView?.register(UserProfilePhotoGridCell.self, forCellWithReuseIdentifier: UserProfilePhotoGridCell.cellId)
        collectionView?.register(HomePostCell.self, forCellWithReuseIdentifier: HomePostCell.cellId)
        collectionView?.register(UserProfileEmptyStateCell.self, forCellWithReuseIdentifier: UserProfileEmptyStateCell.cellId)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
        
        configureAlertController()
    }
    
    private func configureAlertController() {
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let logOutAction = UIAlertAction(title: "Log Out", style: .default) { (_) in
            do {
                try Auth.auth().signOut()
                let loginController = LoginController()
                let navController = UINavigationController(rootViewController: loginController)
                self.present(navController, animated: true, completion: nil)
            } catch let err {
                print("Failed to sign out:", err)
            }
        }
        alertController.addAction(logOutAction)
        
        let deleteAccountAction = UIAlertAction(title: "Delete Account", style: .destructive, handler: nil)
        alertController.addAction(deleteAccountAction)
    }
    
    private func configureUser() {
        guard let user = user else { return }
        
        if user.uid == Auth.auth().currentUser?.uid {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "gear").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleSettings))
        } else {
            let optionsButton = UIBarButtonItem(title: "•••", style: .plain, target: nil, action: nil)
            optionsButton.tintColor = .black
            navigationItem.rightBarButtonItem = optionsButton
        }
        
        navigationItem.title = user.username
        header?.user = user
        
        handleRefresh()
    }
    
    @objc private func handleSettings() {
        present(alertController, animated: true, completion: nil)
    }
    
    @objc private func handleRefresh() {
        guard let uid = user?.uid else { return }
        
        posts.removeAll()
//        isFinishedPaging = false
//        paginatePosts()
        
        //TODO: Replace this with pagination
        Database.database().fetchAllPosts(withUID: uid, completion: { (posts) in
            self.posts = posts
            self.posts.sort(by: { (p1, p2) -> Bool in
                return p1.creationDate.compare(p2.creationDate) == .orderedDescending
            })
            self.collectionView?.reloadData()
            self.collectionView?.refreshControl?.endRefreshing()
            
        }) { (err) in
            self.collectionView?.refreshControl?.endRefreshing()
        }
        
        header?.reloadData()
    }
    
//    private func paginatePosts() {
//        guard let uid = self.user?.uid else { return }
//
//        var query = Database.database().reference().child("posts").child(uid).queryOrdered(byChild: "creationDate")
//
//        if posts.count > 0 {
//            let value = posts.last?.creationDate.timeIntervalSince1970
//            query = query.queryEnding(atValue: value)
//        }
//
//        query.queryLimited(toLast: UInt(pagingCount)).observeSingleEvent(of: .value, with: { (snapshot) in
//            guard var allObjects = snapshot.children.allObjects as? [DataSnapshot] else {
//                self.collectionView?.refreshControl?.endRefreshing()
//                return
//            }
//
//            allObjects.reverse()
//
//            if allObjects.count < self.pagingCount {
//                self.isFinishedPaging = true
//            } else {
//                self.isFinishedPaging = false
//            }
//
//            if self.posts.count > 0 && allObjects.count > 0 {
//                allObjects.removeFirst()
//            }
//
//            if allObjects.count == 0 {
//                self.collectionView?.refreshControl?.endRefreshing()
//            }
//
//            allObjects.forEach({ (snapshot) in
//                let postId = snapshot.key
//
//                Database.database().fetchPost(withUID: uid, postId: postId, completion: { (post) in
//                    self.posts.append(post)
//                    self.collectionView?.reloadData()
//                    self.collectionView?.refreshControl?.endRefreshing()
//
//                }, withCancel: { (err) in
//                    self.collectionView?.refreshControl?.endRefreshing()
//                })
//            })
//        }) { (err) in
//            print("Failed to paginate posts:", err)
//        }
//    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if posts.count == 0 {
            return 1
        }
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if posts.count == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserProfileEmptyStateCell.cellId, for: indexPath)
            return cell
        }
        
//        if indexPath.item == posts.count - 1, !isFinishedPaging {
//            paginatePosts()
//        }
        
        if isGridView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserProfilePhotoGridCell.cellId, for: indexPath) as! UserProfilePhotoGridCell
            cell.post = posts[indexPath.item]
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomePostCell.cellId, for: indexPath) as! HomePostCell
        cell.post = posts[indexPath.item]
        cell.delegate = self
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if header == nil {
            header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: UserProfileHeader.headerId, for: indexPath) as? UserProfileHeader
            header?.delegate = self
            header?.user = user
        }
        return header!
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
    
extension UserProfileController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if posts.count == 0 {
            let emptyStateCellHeight = (view.safeAreaLayoutGuide.layoutFrame.height - 200)
            return CGSize(width: view.frame.width, height: emptyStateCellHeight)
        }
        
        if isGridView {
            let width = (view.frame.width - 2) / 3
            return CGSize(width: width, height: width)
        } else {
            let dummyCell = HomePostCell(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 1000))
            dummyCell.post = posts[indexPath.item]
            dummyCell.layoutIfNeeded()
            
            var height: CGFloat = dummyCell.header.bounds.height
            height += view.frame.width
            height += 24 + 2 * dummyCell.padding //bookmark button + padding
            height += dummyCell.captionLabel.intrinsicContentSize.height + 8
            
            //TODO: unsure why this is needed
            height += 8
            
            return CGSize(width: view.frame.width, height: height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
}

//MARK: - UserProfileHeaderDelegate

extension UserProfileController: UserProfileHeaderDelegate {
    
    func didChangeToGridView() {
        isGridView = true
        collectionView?.reloadData()
    }
    
    func didChangeToListView() {
        isGridView = false
        collectionView?.reloadData()
    }
}

