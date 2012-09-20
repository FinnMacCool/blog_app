class AddIndices < ActiveRecord::Migration
  def change
    add_index :users, :name, unique: true
    add_index :categories, :name, unique: true
    remove_index :tags, :value
    add_index :tags, :value, unique: true
    add_index :posts, :title, unique: true
  end
end
