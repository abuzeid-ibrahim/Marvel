//
//  RecipesTableController.swift
//  Marvel
//
//  Created by abuzeid on 23.09.20.
//  Copyright © 2020 abuzeid. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

final class FeedTableController: UITableViewController {
    private let viewModel: FeedViewModelType
    private var comicsList: [Feed] { viewModel.dataList }
    private let disposeBag = DisposeBag()

    init(viewModel: FeedViewModelType = FeedViewModel()) {
        self.viewModel = viewModel
        super.init(style: .grouped)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }

    lazy var heroes: HeroesController = {
        let heroesViewModel = HeroesViewModel()
        let controller = HeroesController(viewModel: heroesViewModel)
        heroesViewModel.selectHero
            .bind(to: self.viewModel.selectHeroById)
            .disposed(by: self.disposeBag)
        return controller
    }()

    private var header: UIView {
        let view = UIView()
        view.addSubview(heroes.view)
        heroes.view.setConstrainsEqualToParentEdges(top: 8, bottom: 8, leading: 8, trailing: 8)
        view.backgroundColor = .white
        return view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Marvel"
        setupTableView()
        bind()
    }

    private func setupTableView() {
        tableView.prefetchDataSource = self
        tableView.register(FeedTableCell.self)
        tableView.rowHeight = 700
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
    }

    private func bind() {
        viewModel.reloadFields
            .asDriver(onErrorJustReturn: .all)
            .drive(onNext: { [weak self] row in
                if case let DataChange.insertItems(indexes) = row {
                    self?.tableView.reloadRows(at: indexes, with: .none)
                } else if case DataChange.all = row {
                    self?.tableView.reloadData()
                }
            })
            .disposed(by: disposeBag)
        viewModel.error
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: show(error:)).disposed(by: disposeBag)
    }
}

// MARK: - Table view data source

extension FeedTableController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comicsList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FeedTableCell.identifier, for: indexPath) as! FeedTableCell
        cell.setData(of: comicsList[indexPath.row])
        return cell
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return header
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
}

// MARK: - UITableViewDataSourcePrefetching

extension FeedTableController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        viewModel.prefetchItemsAt(prefetch: true, indexPaths: indexPaths)
    }

    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        viewModel.prefetchItemsAt(prefetch: false, indexPaths: indexPaths)
    }
}
