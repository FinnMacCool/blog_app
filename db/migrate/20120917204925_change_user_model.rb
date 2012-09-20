class ChangeUserModel < ActiveRecord::Migration
  def change
    remove_column :users, :name
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :email, :string
    add_column :users, :task_area, :string
    add_column :users, :introduction, :text
    
    add_index :users, :email, unique: true
  end
end
