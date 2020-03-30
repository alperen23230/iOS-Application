//
//  VideosTableViewController.swift
//  GelecekBilimde
//
//  Created by Alperen Ünal on 22.09.2019.
//  Copyright © 2019 Burak Furkan Asilturk. All rights reserved.
//

import UIKit

class VideosTableViewController: UITableViewController {
    
    var videosViewModel: VideosViewModel!
    var fetchingMore = false

    override func viewDidLoad() {
        super.viewDidLoad()
        //NavBar title customizations
        navigationController?.navigationBar.barTintColor = UIColor.barTintColor
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = attributes
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshVideos), name: NSNotification.Name(rawValue: "videoBookmarkChangeFromBookmark"), object: nil)
        videosViewModel = VideosViewModel()
        videosViewModel.loadVideosCache()
        
        //This is for setting table view's background color
        self.tableView.backgroundColor = UIColor.tableViewBgColor
        
        videosViewModel.getVideos {
            DispatchQueue.main.async {
                self.videosViewModel.loadVideosCache()
                self.tableView.reloadData()
            }
        }
    }
    
    override func scrollViewDidScroll(_ scrollView:UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.height * 4 {
            if !fetchingMore {
                getMoreVideos()
            }
        }
    }
    func getMoreVideos(){
        fetchingMore = true
        videosViewModel.getVideos {
            DispatchQueue.main.async {
                self.fetchingMore = false
                self.videosViewModel.loadVideosCache()
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func refreshVideos(){
         videosViewModel.loadVideosCache()
         tableView.reloadData()
     }
}

// MARK: - Table view data source
extension VideosTableViewController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 350
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return videosViewModel.videosCache?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let currentVideo = videosViewModel.videosCache?[indexPath.row] else { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(withIdentifier: "videoCell", for: indexPath) as! VideoTableViewCell
        cell.delegate = self
        cell.setVideo(videoCache: currentVideo)
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToVideoContent", sender: nil)
    }
    
}

//MARK: Prepare for Segue
extension VideosTableViewController {
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = "Geri"
        navigationItem.backBarButtonItem = backItem
        if let destinationVC = segue.destination as? VideoContentViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                let video = videosViewModel.videosCache?[indexPath.row]
                
                guard let videoContent = video else { return }
                
                destinationVC.currentVideo = videoContent
            }
        }
    }
}

//MARK: Video Cell Delegate
extension VideosTableViewController: VideoCellDelegate {
    func didTapBookmark(video: VideoCache) {
        if video.bookmarked {
            //Set False
            videosViewModel.changeVideoBookmark(video: video, state: false)
            videosViewModel.loadVideosCache()
            tableView.reloadData()
        } else {
            //Set True
            videosViewModel.changeVideoBookmark(video: video, state: true)
            videosViewModel.loadVideosCache()
            tableView.reloadData()
        }
    }
}
