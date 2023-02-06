//
//  QuestionCell.swift
//  MathTrainingGame
//
//  Created by Yanunsey on 22/12/22.
//

import UIKit

class QuestionCell: UITableViewCell {

    @IBOutlet weak var questionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bind(at indexPath: IndexPath, to question: Question){
        if indexPath.row == 0  {
            questionLabel.font = UIFont.boldSystemFont(ofSize: 36.0)
        } else {
            questionLabel.font = UIFont.systemFont(ofSize: 18.0)
        }
        
        if let userAnswer = question.userAnswer {
            questionLabel.text = "\(question.text) = \(userAnswer)"
        } else {
            questionLabel.text = "\(question.text) = ? "
        }
    }
    
}
