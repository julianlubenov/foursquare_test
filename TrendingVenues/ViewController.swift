//
//  ViewController.swift
//  TrendingVenues
//
//  Created by Yuliyan Lyubenov on 11.04.20.
//  Copyright © 2020 None. All rights reserved.
//


import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var trendingVenuesVC: TrendingVenuesViewController?
    var aboutVC: AboutViewController?
    
    var currentTabIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle(for: ViewController.self))
        self.trendingVenuesVC = storyBoard.instantiateViewController(identifier: "TrendingVenuesViewController") as? TrendingVenuesViewController
        self.aboutVC = storyBoard.instantiateViewController(identifier: "AboutViewController") as? AboutViewController
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.addTrendingVenuesVC()
    }
    
    func addTrendingVenuesVC() {
        if let trendingVenuesVC = self.trendingVenuesVC {
            self.addChild(trendingVenuesVC)
            trendingVenuesVC.view.frame = self.containerView.frame
            self.aboutVC?.view.removeFromSuperview()
            trendingVenuesVC.view.translatesAutoresizingMaskIntoConstraints = false
            self.containerView.addSubview(trendingVenuesVC.view)
            if let bindings = ["tvView": trendingVenuesVC.view] as? [String: UIView] {
                self.containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[tvView]-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: bindings))
                self.containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[tvView]-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: bindings))
            }
            trendingVenuesVC.didMove(toParent: self)
            
        }
    }
    
    func addAboutVC() {
        if let aboutVC = self.aboutVC {
            self.addChild(aboutVC)
            aboutVC.view.frame = self.containerView.frame
            aboutVC.view.translatesAutoresizingMaskIntoConstraints = false
            self.trendingVenuesVC?.view.removeFromSuperview()
            self.containerView.addSubview(aboutVC.view)
            if let bindings = ["aboutView": aboutVC.view] as? [String: UIView] {
                self.containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[aboutView]-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: bindings))
                self.containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[aboutView]-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: bindings))
            }
            aboutVC.didMove(toParent: self)
            
        }
    }
    
    @IBAction @objc func switchedTab(sender: AnyObject) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            if (currentTabIndex != 0) {
                self.addTrendingVenuesVC()
            }
            currentTabIndex = 0
            break
        case 1:
            if (currentTabIndex != 1) {
                self.addAboutVC()
            }
            currentTabIndex = 1
            break
        default:
            break
        }
    }


}

