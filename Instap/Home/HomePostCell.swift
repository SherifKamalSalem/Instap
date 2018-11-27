//
//  HomePostCell.swift
//  Instap
//
//  Created by Sherif Kamal on 8/1/18.
//  Copyright © 2018 Sherif Kamal. All rights reserved.
//

import UIKit

protocol HomePostCellDelegate {
    func didTapComment(post: Post)
    func didTapUser(user: User)
    func didTapOptions(post: Post)
    func didLike(for cell: HomePostCell)
}

class HomePostCell: UICollectionViewCell {
    
    var delegate: HomePostCellDelegate?
    
    var post: Post? {
        didSet {
            configurePost()
        }
    }
    
    let header = HomePostCellHeader()
    
    let captionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    let padding: CGFloat = 12
    
    private let photoImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = UIColor(white: 0.95, alpha: 1)
        return iv
    }()
    
    private lazy var likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "like_unselected").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        return button
    }()
    
    private lazy var commentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "comment").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleComment), for: .touchUpInside)
        return button
    }()
    
    private let sendMessageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "send2").withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()
    
    private let bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ribbon").withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()
    
    private let likeCounter: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .black
        return label
    }()
    
    static var cellId = "homePostCellId"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    private func sharedInit() {
        addSubview(header)
        header.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor)
        header.delegate = self
        
        addSubview(photoImageView)
        photoImageView.anchor(top: header.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor)
        photoImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
        
        setupActionButtons()

        addSubview(likeCounter)
        likeCounter.anchor(top: likeButton.bottomAnchor, left: leftAnchor, paddingTop: padding, paddingLeft: padding)
        
        addSubview(captionLabel)
        captionLabel.anchor(top: likeCounter.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: padding - 6, paddingLeft: padding, paddingRight: padding)
    }
    
    private func setupActionButtons() {
        let stackView = UIStackView(arrangedSubviews: [likeButton, commentButton, sendMessageButton])
        stackView.distribution = .fillEqually
        stackView.alignment = .top
        stackView.spacing = 16
        addSubview(stackView)
        stackView.anchor(top: photoImageView.bottomAnchor, left: leftAnchor, paddingTop: padding, paddingLeft: padding)
        
        addSubview(bookmarkButton)
        bookmarkButton.anchor(top: photoImageView.bottomAnchor, right: rightAnchor, paddingTop: padding, paddingRight: padding)
    }
    
    private func configurePost() {
        guard let post = post else { return }
        header.user = post.user
        photoImageView.loadImage(urlString: post.imageUrl)
        likeButton.setImage(post.likedByCurrentUser == true ? #imageLiteral(resourceName: "like_selected").withRenderingMode(.alwaysOriginal) : #imageLiteral(resourceName: "like_unselected").withRenderingMode(.alwaysOriginal), for: .normal)
        setLikes(to: post.likes)
        setupAttributedCaption()
    }
    
    private func setupAttributedCaption() {
        guard let post = self.post else { return }
        
        let attributedText = NSMutableAttributedString(string: post.user.username, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: " \(post.caption)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
        attributedText.append(NSAttributedString(string: "\n\n", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 4)]))
        
        let timeAgoDisplay = post.creationDate.timeAgoDisplay()
        attributedText.append(NSAttributedString(string: timeAgoDisplay, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.gray]))
        captionLabel.attributedText = attributedText
    }
    
    private func setLikes(to value: Int) {
        if value <= 0 {
            likeCounter.text = ""
        } else if value == 1 {
            likeCounter.text = "1 like"
        } else {
            likeCounter.text = "\(value) likes"
        }
    }
    
    @objc private func handleLike() {
        delegate?.didLike(for: self)
    }
    
    @objc private func handleComment() {
        guard let post = post else { return }
        delegate?.didTapComment(post: post)
    }
}

//MARK: - HomePostCellHeaderDelegate

extension HomePostCell: HomePostCellHeaderDelegate {
    
    func didTapUser() {
        guard let user = post?.user else { return }
        delegate?.didTapUser(user: user)
    }
    
    func didTapOptions() {
        guard let post = post else { return }
        delegate?.didTapOptions(post: post)
    }
}








