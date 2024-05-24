//
//  ViewController.swift
//  super-duper to-do
//
//  Created by Даниял on 29.04.2024.
//  Copyright © 2024 All rights reserved.
//  Прошу не судить строго 🙃 Я способен на большее, только скажите что именно подправить/добавить

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    var dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(K.keyForDataFilePath)
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        loadItems()
    }
    
    //MARK: - UpdateUI || Tableview Datasource Methods // Запускаются после viewDidLoad и при вызове tableView.reloadData()
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath)
        let item = itemArray[indexPath.row]
        
        cell.accessoryType = item.done ? .checkmark: .none
        
        if #available(iOS 14.0, *) {
            var content = cell.defaultContentConfiguration()
            content.text = item.title
            cell.contentConfiguration = content
        } else {
            cell.textLabel?.text = item.title
        }
        
        return cell
    }
    
    //MARK: - did Select | TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                
        // При первом нажатии ставим галочку, при втором - удаляем
        if !itemArray[indexPath.row].done {
            
            itemArray[indexPath.row].done = !itemArray[indexPath.row].done
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            context.delete(itemArray[indexPath.row])
            itemArray.remove(at: indexPath.row)
        }
        
        saveItems()
    }
    
    
    //MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {

        let alert = UIAlertController(title: "Add New Item", message: nil, preferredStyle: .alert)
        var textField = UITextField()
        
        //        Создание (но не добавление) кнопки "Add Item" во всплывающем окне и действия при нажатии на неё:
        let action = UIAlertAction(title: "Add Item", style: .default) { [weak self] _ in
            guard let self = self, let text = textField.text, !text.isEmpty else { return }

            //  Cоздает экземпляр Core Data и добавляет его в контекст
            let newItem = Item(context: context)
            newItem.title = text
            newItem.done = false
            itemArray.append(newItem)
            saveItems()
        }
        
        // добавление текстового поля в alert
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        //        добавление кнопки "Add Item" в alert
        alert.addAction(action)
        
        // Показ окна alert
        present(alert, animated: true)
    }
}
//MARK: - Search bar methods

extension TodoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // request - настройки запроса (пустые)
        let request = Item.fetchRequest()
        
        if !searchBar.text!.isEmpty {
            // настройки запроса
            request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
            // настройки сортировки
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        }
        
        loadItems(with: request)
    }
}

//MARK: - Data Methods
extension TodoListViewController {
    
    func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        tableView.reloadData()
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest()) {
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Eroor fetching data from context \(error)")
        }
        tableView.reloadData()
    }
}
