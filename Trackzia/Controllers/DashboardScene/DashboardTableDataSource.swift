//
//  DashboardTableDataSource.swift
//  Trackzia
//
//  Created by Rohan Bhale on 08/12/18.
//  Copyright © 2018 Private. All rights reserved.
//

import UIKit

protocol DashboardCellModel {
    var text: String { get }
    var showAddButton: Bool { get }
    var isSelected: Bool { get }
    var cellIdentifier: String { get }
}

protocol DashboardTableDataSourceDelegate {
    func configure(_ cell: UITableViewCell, model: DashboardCellModel)
}

class DashboardTableDataSource<Cell: UITableViewCell, Model: DashboardCellModel>: NSObject, UITableViewDataSource {
    
    typealias ACell = Cell
    typealias AModel = Model
    
    var models: [[Model]]
    var delegate: DashboardTableDataSourceDelegate!
    var tableView: UITableView
    
    init(models: [[Model]], delegate: DashboardTableDataSourceDelegate, tableView: UITableView) {
        self.models = models
        self.delegate = delegate
        self.tableView = tableView
        super.init()
        self.tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.section][indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: model.cellIdentifier, for: indexPath) as! Cell
        delegate.configure(cell, model: model)
        return cell
    }
}



