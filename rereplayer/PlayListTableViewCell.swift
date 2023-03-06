//
//  PlayListTableViewCell.swift
//  rereplayer
//
//  Created by soojin jeong on 2023/01/11.
//

import UIKit

class PlayListTableViewCell: UITableViewCell {

    
    
    @IBOutlet var lbFilenName: UILabel!
    @IBOutlet var lbAlbumName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected == true{
            lbFilenName.font = UIFont.boldSystemFont(ofSize: 20)
        }else{
            lbFilenName.font = UIFont.boldSystemFont(ofSize: 10)
        }
        // Configure the view for the selected state
        //nameLabel.font = UIFont.boldSystemFont(ofSize: 20)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool){
            
    } // animate between regular and highlighted state

}
