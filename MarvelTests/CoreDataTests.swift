//
//  CoreDataTests.swift
//  MarvelTests
//
//  Created by abuzeid on 29.09.20.
//  Copyright © 2020 abuzeid. All rights reserved.
//

@testable import Marvel
import XCTest

final class CoreDataTests: XCTestCase {

    func test_DB_CRUD_forHero() throws {
        CoreDataIO.shared.clearCache(for: .heroes)
        XCTAssertEqual(CoreDataIO.shared.load(offset: 0, entity: .heroes).count, 0)

        let heroes = [Hero(id: 1, name: "Abozaid", thumbnail: .init(path: "https://www.google.com/imagename", thumbnailExtension: "png")),
                      Hero(id: 2, name: "Abozaid", thumbnail: .init(path: "https://www.google.com/imagename", thumbnailExtension: "png")),
                      Hero(id: 3, name: "Abozaid", thumbnail: .init(path: "https://www.google.com/imagename", thumbnailExtension: "png"))]
        let exp = expectation(description: "Tests")

        CoreDataIO.shared.save(data: heroes, entity: .heroes, onComplete: { _ in
            XCTAssertEqual(CoreDataIO.shared.load(offset: 0, entity: .heroes).count, 3)
            exp.fulfill()
        })

        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func test_DB_CRUD_forFeed() throws {
        CoreDataIO.shared.clearCache(for: .feed)
        XCTAssertEqual(CoreDataIO.shared.load(offset: 0, entity: .feed).count, 0)

        let feed = [Feed(pid: 1, id: 1, title: "Abozaid", modified: nil,
                         thumbnail: .init(path: "https://www.google.com/imagename", thumbnailExtension: "png")),
                    Feed(pid: 1, id: 3, title: "Abozaid", modified: nil,
                         thumbnail: .init(path: "https://www.google.com/imagename", thumbnailExtension: "png")),
                    Feed(pid: 2, id: 2, title: "Abozaid", modified: nil,
                         thumbnail: .init(path: "https://www.google.com/imagename", thumbnailExtension: "png"))]
        let exp = expectation(description: "af")
        CoreDataIO.shared.save(data: feed, entity: .feed, onComplete: { _ in
            XCTAssertEqual(CoreDataIO.shared.load(offset: 0, entity: .feed).count, 3)
            XCTAssertEqual(CoreDataIO.shared.load(offset: 0, entity: .feed, predicate: .feed(pid: 1)).count, 2)
            XCTAssertEqual(CoreDataIO.shared.load(offset: 0, entity: .feed, predicate: .feed(pid: 2)).count, 1)
            exp.fulfill()
        })
        wait(for: [exp], timeout: 0.1)
    }
}
