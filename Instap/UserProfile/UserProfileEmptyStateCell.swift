//
//  UserProfileEmptyStateCell.swift
//  Instap
//
//  Created by Sherif Kamal on 7/27/18.
//  Copyright © 2018 Sherif Kamal. All rights reserved.
//

import UIKit

class UserProfileEmptyStateCell: UICollectionViewCell {
    
    private let noPostsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.text = "No posts yet."
        label.textColor = .lightGray
        label.textAlignment = .center
        return label
    }()
    
    static var cellId = "userProfileEmptyStateCellId"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    private func sharedInit() {
        addSubview(noPostsLabel)
        noPostsLabel.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
    }
}
