//
//  ListableItem.swift
//  trailer
//
//  Created by Paul Tsochantaris on 28/08/2017.
//  Copyright © 2017 Paul Tsochantaris. All rights reserved.
//

import Foundation

enum ListableItem: Equatable {
    case pullRequest(PullRequest)
    case issue(Issue)

    static func ==(lhs: ListableItem, rhs: ListableItem) -> Bool {
        switch lhs {
        case .pullRequest(let pr1):
            switch rhs {
            case .pullRequest(let pr2):
                return pr1 == pr2
            default: return false
            }
        case .issue(let issue1):
            switch rhs {
            case .issue(let issue2):
                return issue1 == issue2
            default: return false
            }
        }
    }

	var pullRequest: PullRequest? {
		switch self {
		case .pullRequest(let p):
			return p
		default:
			return nil
		}
	}

	var issue: Issue? {
		switch self {
		case .issue(let i):
			return i
		default:
			return nil
		}
	}

    func printDetails() {
        switch self {
        case .pullRequest(let i):
            i.printDetails()
        case .issue(let i):
            i.printDetails()
        }
    }

    func openURL() {
        let url: URL
        switch self {
        case .pullRequest(let i):
            url = i.url
        case .issue(let i):
            url = i.url
        }
        log("Opening url: [*\(url)*]")
        let p = Process()
        p.launchPath = "/usr/bin/open"
        p.arguments = [url.absoluteString]
        p.launch()
    }
}
