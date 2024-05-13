//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)/*.first?.appendingPathComponent(K.keyForDataFilePath)*/)
        loadItems()
    }
    
    //MARK: - UpdateUI | Tableview Datasource Methods
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
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    
    //MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add New Item", message: nil, preferredStyle: .alert)
        
        var textField = UITextField()
        
        //        Создание (но не добавление) кнопки "Add Item" во всплывающем окне и действия при нажатии на неё:
        let action = UIAlertAction(title: "Add Item", style: .default) { [self] action in
            
            if let text = textField.text, !text.isEmpty {
                
                // Создаётся объект в контексте и ссылка на этот объект присваивается константе newItem
                let newItem = Item(context: context)
                newItem.title = text
                newItem.done = false
                
                itemArray.append(newItem)
                saveItems()
            }
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
    //MARK: - Model Manipulation Methods
    
    func saveItems() {
        do {
            // сохраняем контекст в CoreData
            try context.save()
            print("Сохранение контекста прошло успешно")
        } catch {
            print("Ошибка сохранение контекста: \(error)")
        }
        tableView.reloadData()
    }
    
    func loadItems() {
        let request/*: NSFetchRequest<Item>*/ = Item.fetchRequest()
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Ошибка получения данных из базы + из контекста: \(error)")
        }
    }
}

