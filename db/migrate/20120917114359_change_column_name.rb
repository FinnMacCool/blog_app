class ChangeColumnName < ActiveRecord::Migration
  def change
    remove_column :tags, :value
    add_column :tags, :name, :string
  end
end
