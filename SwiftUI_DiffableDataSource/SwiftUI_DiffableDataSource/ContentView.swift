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

class Contact: NSObject {
    let name: String
    var isFavourite = false
    
    init(name: String) {
        self.name = name
    }
}

class ContactViewModel: ObservableObject {
    @Published var name = ""
    @Published var isFavourite = false
}

struct ContactRowView: View {
    
    @ObservedObject var viewModel: ContactViewModel
    
    var body: some View {
        HStack {
            Image(systemName: "person.fill")
            Text(viewModel.name)
            Spacer()
            Image(systemName: viewModel.isFavourite ? "star.fill" : "star")
                .font(.system(size: 24))
        }.padding(20)
    }
}

class ContactCell: UITableViewCell {
    
    let viewModel = ContactViewModel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let hostingController = UIHostingController(rootView: ContactRowView(viewModel: viewModel))
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

class ContactsSource: UITableViewDiffableDataSource<SectionType, Contact> {
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
}

class DiffableTableViewController: UITableViewController {
    
    lazy var source = ContactsSource.init(tableView: self.tableView) { (tv, indexPath, contact) -> UITableViewCell? in
        
        let cell = ContactCell(style: .default, reuseIdentifier: nil)
        cell.viewModel.name = contact.name
        cell.viewModel.isFavourite = contact.isFavourite
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Contacts"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(handleAdd))
        setupSource()
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            completion(true)
            
            var snapshot = self.source.snapshot()
            guard let contact = self.source.itemIdentifier(for: indexPath) else { return }
            snapshot.deleteItems([contact])
            self.source.apply(snapshot)
            
        }
        
        let favouriteAction = UIContextualAction(style: .normal, title: "Favourite") { (action, view, completion) in
            completion(true)
            
            var snapshot = self.source.snapshot()
            guard let contact = self.source.itemIdentifier(for: indexPath) else { return }
            contact.isFavourite.toggle()
            snapshot.reloadItems([contact])
            self.source.apply(snapshot)
            
        }
        
        return .init(actions: [deleteAction, favouriteAction])
    }
    
    @objc
    private func handleAdd() {
        let formView = ContactForvView { (name, sectionType)  in
            
            self.dismiss(animated: true, completion: nil)
            
            var snapshot = self.source.snapshot()
            snapshot.appendItems([.init(name: name)], toSection: sectionType)
            self.source.apply(snapshot)
        }
        
        let hostingController = UIHostingController(rootView: formView)
        present(hostingController, animated: true, completion: nil)
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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

struct ContactForvView: View {
    
    var didAddContact: (String, SectionType) -> Void = { _,_ in }
    @State private var bindableName: String = ""
    @State private var bindableSection = SectionType.ceo
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Name", text: $bindableName)
            Picker(selection: $bindableSection, label: Text("")) {
                Text("CEO").tag(SectionType.ceo)
                Text("Peasants").tag(SectionType.peasants)
            }.pickerStyle(SegmentedPickerStyle())
            Button(action: {
                self.didAddContact(self.bindableName, self.bindableSection)
            }, label: {
                HStack {
                    Spacer()
                    Text("Add")
                        .foregroundColor(.white)
                    Spacer()
                }
                    .padding()
                    .background(Color.blue)
            }).cornerRadius(5)
            Spacer()
        }.padding()
    }
}

struct ContentView: View {
    var body: some View {
        DiffableContainer()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        DiffableContainer()
    }
}

struct ContactFormPreview: PreviewProvider {
    static var previews: some View {
        ContactForvView()
    }
}
