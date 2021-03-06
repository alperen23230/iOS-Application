//
//  VideoTableViewCell.swift
//  GelecekBilimde
//
//  Created by Alperen Ünal on 22.09.2019.
//  Copyright © 2019 Burak Furkan Asilturk. All rights reserved.
//

import UIKit
import SDWebImage

protocol VideoCellDelegate {
    func didTapBookmark(video: VideoCache)
}

class VideoTableViewCell: UITableViewCell {

    @IBOutlet weak var videoThumbnailImageView: UIImageView!
    @IBOutlet weak var videoBookmarkImageView: UIImageView!
    @IBOutlet weak var videoTitleLabel: UILabel!
    @IBOutlet weak var videoDateLabel: UILabel!
    
    var currentVideo: VideoCache!
    var delegate: VideoCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let tap = UITapGestureRecognizer(target: self, action: #selector(bookmarkClicked))
        tap.numberOfTapsRequired = 1
        
        videoBookmarkImageView.isUserInteractionEnabled = true
        
        videoBookmarkImageView.addGestureRecognizer(tap)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        videoThumbnailImageView.layer.cornerRadius = 15.0
        videoThumbnailImageView.clipsToBounds = true
    }
    
    @objc func bookmarkClicked(){
        UIView.animate(withDuration: 0.2, delay: 0,  options: [], animations: {
            self.videoBookmarkImageView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            DispatchQueue.main.async {
                self.videoBookmarkImageView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
        }) { (finished) in
            self.delegate?.didTapBookmark(video: self.currentVideo)
        }
    }
    
    func setVideo(videoCache: VideoCache){
        currentVideo = videoCache
        videoThumbnailImageView.contentMode = .scaleAspectFill
        let dateComponent = findDateFromString(dateString: videoCache.videoDate)
        videoTitleLabel.text = videoCache.videoTitle
        videoDateLabel.text = "\(String(describing: dateComponent.day!))/\(String(describing: dateComponent.month!))/\(String(describing: dateComponent.year!))"
        if videoCache.bookmarked {
            videoBookmarkImageView.image = UIImage(named: "bookmarked")
        } else {
            videoBookmarkImageView.image = UIImage(named: "unbookmarked")
        }
        guard let url = URL(string: videoCache.videoImageURL) else { return }
        videoThumbnailImageView.sd_setImage(with: url){ (image, error, cache, urls) in
            if (error != nil) {
                self.videoThumbnailImageView.image = UIImage(named: "youtubePlaceHolder")
            } else {
                self.videoThumbnailImageView.image = image
            }
        }
    }
    
    func findDateFromString(dateString: String) -> DateComponents {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let date = dateFormatter.date(from:dateString)!
        let calender = Calendar.current
        let dateComponent = calender.dateComponents([.year, .month, .day], from: date)
        return dateComponent
    }
    
}
