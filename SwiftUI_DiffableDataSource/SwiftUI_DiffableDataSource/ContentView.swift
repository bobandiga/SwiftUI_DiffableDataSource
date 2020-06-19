//
//  ContentView.swift
//  SwiftUI_DiffableDataSource
//
//  Created by Максим Шаптала on 05.06.2020.
//  Copyright © 2020 Максим Шаптала. All rights reserved.
//

import SwiftUI

enum SectionType {
    case ceo, peasants
}

struct Contact: Hashable {
    let name: String
}

struct ContactRowView: View {
    var body: some View {
        Text("Row")
    }
}

class ContactCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let hostingController = UIHostingController(rootView: ContactRowView())
        addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class DiffableTableViewController: UITableViewController {
    
    lazy var source = UITableViewDiffableDataSource<SectionType, Contact>.init(tableView: self.tableView) { (tv, indexPath, contact) -> UITableViewCell? in
        
        let cell = ContactCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = contact.name
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Contacts"
        
        setupSource()
    }
    
    private func setupSource() {
        
        var snapshot = source.snapshot()
        snapshot.appendSections([.ceo, .peasants])
        snapshot.appendItems([
            .init(name: "Diana"),
            .init(name: "Maks")
        ], toSection: .ceo)
        snapshot.appendItems([
            .init(name: "Some ")
        ], toSection: .peasants)
        
        source.apply(snapshot)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = section == 0 ? "SEO" : "Peasants"
        return label
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
}

struct DiffableContainer: UIViewControllerRepresentable {
    func makeUIViewController(context: UIViewControllerRepresentableContext<DiffableContainer>) -> UIViewController {
        let navigation = UINavigationController(rootViewController: DiffableTableViewController(style: .insetGrouped))
        return navigation
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<DiffableContainer>) {
        
    }
    
    
}

struct ContentView: View {
    var body: some View {
        Text("Hello, World!")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        DiffableContainer()
    }
}
