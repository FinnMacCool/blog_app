class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :password_digest
      t.string :password
      t.string :password_confirmation

      t.timestamps
    end
  end
end
