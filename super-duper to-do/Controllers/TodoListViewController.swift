//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    var count = 0
    var dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(K.keyForDataFilePath)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        print(dataFilePath)
        loadItems()
        print(123)
        
    }
    
    //MARK: - UpdateUI || Tableview Datasource Methods
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
            
            if let text = textField.text {
                if !text.isEmpty {
                    
                    let newItem = Item()
                    newItem.title = text
                    
                    itemArray.append(newItem)
                    saveItems()
                }
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
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(itemArray)
            // Сохраняем данные в файл
            try data.write(to: dataFilePath!)
        } catch {
            print("Ошибка при кодировании данных: \(error)")
        }
        tableView.reloadData()
    }
    
    func loadItems() {
        if let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            do {
                itemArray = try decoder.decode([Item].self, from: data)
            } catch {
                print("Ошибка при декодировании данных: \(error)")
            }
        }
    }
}
