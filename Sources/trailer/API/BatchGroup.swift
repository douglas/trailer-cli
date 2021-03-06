//
//  BatchGroup.swift
//  trailer
//
//  Created by Paul Tsochantaris on 18/08/2017.
//  Copyright © 2017 Paul Tsochantaris. All rights reserved.
//

import Foundation

struct BatchGroup: Ingesting {
	let name = "nodes"

	typealias NodeBlock = ([AnyHashable : Any])->Void

	private var idsToGroups = [String : Group]()
	private let originalTemplate: Group
	private let nextCount: Int
	private let perNodeBlock: NodeBlock?

	init(templateGroup: Group, idList: [String], startingCount: Int = 0, perNodeBlock: NodeBlock? = nil) {
		self.perNodeBlock = perNodeBlock
		originalTemplate = templateGroup
		var index = startingCount
		for id in idList {
			var t = templateGroup
			t.name = templateGroup.name + "\(index)"
			idsToGroups[id] = t
			index += 1
		}
		nextCount = index
	}

	var queryText: String {
		if let templateGroup = idsToGroups.values.first {
			return "nodes(ids: [\"" + pageOfIds.joined(separator: "\",\"") + "\"]) { " + templateGroup.fields.map ({ $0.queryText }).joined(separator: " ") + " }"
		} else {
			return ""
		}
	}

	var fragments: [Fragment] {
		var fragments = [Fragment]()
		for f in idsToGroups.values {
			let newFragments = f.fragments
			fragments.append(contentsOf: newFragments)
		}
		return fragments
	}

	private var pageOfIds: [String] {
		let k = idsToGroups.keys.sorted()
		let max = min(config.pageSize, k.count)
		return Array<String>(k[0 ..< max])
	}

	func ingest(query: Query, pageData: Any, parent: Parent?, level: Int) -> [Query] {
		log(level: .debug, indent: level, "Ingesting batch group \(name)")
		guard let nodes = pageData as? [[AnyHashable : Any]] else { return [] }

		var extraQueries = [Query]()

		let page = pageOfIds
		let newIds = idsToGroups.keys.filter { !page.contains($0) }
		if !newIds.isEmpty {
			let nextPage = Query(name: query.name, rootElement: BatchGroup(templateGroup: originalTemplate, idList: newIds, startingCount: nextCount, perNodeBlock: perNodeBlock), parent: parent, subQuery: true)
			extraQueries.append(nextPage)
		}

		for n in nodes {
			if let id = n["id"] as? String, let group = idsToGroups[id] {
				let newQueries = group.ingest(query: query, pageData: n, parent: parent, level: level+1)
				extraQueries.append(contentsOf: newQueries)
				perNodeBlock?(n)
			}
		}

		if !extraQueries.isEmpty {
			log(level: .debug, indent: level, "\(name) will need further paging")
		}
		return extraQueries
	}
}
