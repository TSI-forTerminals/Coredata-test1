//
//  ContentView.swift
//  Coredata-test1
//
//  Created by 城川一理 on 2022/10/19.
//

import SwiftUI
import CoreData

struct ContentView: View {
    /// 被管理オブジェクトコンテキスト（ManagedObjectContext）の取得
    @Environment(\.managedObjectContext) private var context
    /// データ取得処理
    @FetchRequest(
        entity: M_CATEGORY.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \M_CATEGORY.updDateTime, ascending: true)],
        predicate: nil
    ) private var categories: FetchedResults<M_CATEGORY>

    @State private var searchText: String = ""
    
    var body: some View {
        NavigationView {
            /// 取得したデータをリスト表示
            List {
                ForEach(categories) { category in
                    
                    /// タスクの表示
                    HStack {
                        Image(systemName: category.checked ? "checkmark.circle.fill" : "circle")
                        Text("\(category.categoryCode!)")
                        Text("\(category.categoryName!)")
                        Spacer()
                    }
                    
                    /// タスクをタップでcheckedフラグを変更する
                    .contentShape(Rectangle())
                    .onTapGesture {
                        category.checked.toggle()
                        try? context.save()
                    }
                }
                .onDelete(perform: deleteTasks)
            }
            .navigationTitle("部門リスト")
            /// ツールバーの設定
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AddTaskView()) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())// iPhoneとiPadの見え方を同じにする
        .searchable(text: $searchText, prompt: "検索")
        // searchableの下に追加
        .onChange(of: searchText) { newValue in
            search(text: newValue)
        }
        
    }
    private func search(text: String) {
    if text.isEmpty {
        categories.nsPredicate = nil // ①
    } else {
        let titlePredicate: NSPredicate = NSPredicate(format: "name contains %@", text) // ②
        //let contentPredicate: NSPredicate = NSPredicate(format: "content contains %@", text) // ③
        //tasks.nsPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [titlePredicate, contentPredicate]) //　④
        categories.nsPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [titlePredicate]) //　④
    }
    }
    /// タスクの削除
    /// - Parameter offsets: 要素番号のコレクション
    func deleteTasks(offsets: IndexSet) {
        for index in offsets {
            context.delete(categories[index])
        }
        try? context.save()
    }

}
/// タスク追加View
struct AddTaskView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.presentationMode) var presentationMode
    @State private var categorycode = ""
    @State private var categoryname = ""
    
    var body: some View {
        Form {
            Section() {
                TextField("部門コードを入力", text: $categorycode)
                TextField("部門名を入力", text: $categoryname)
            }
        }
        .navigationTitle("部門追加")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("保存") {
                    /// 部門新規登録処理
                    let newCategory = M_CATEGORY(context: context)
                    newCategory.categoryCode = categorycode
                    newCategory.categoryName = categoryname
                    newCategory.insDateTime = Date()
                    newCategory.updDateTime = Date()
                    newCategory.checked = false
                    
                    try? context.save()
 
                    /// 現在のViewを閉じる
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
