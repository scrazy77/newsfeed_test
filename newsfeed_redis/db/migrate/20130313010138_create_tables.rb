class CreateTables < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string  :name
      t.timestamps
    end
    create_table :posts do |t|
      t.integer :user_id
      t.string :title
      t.timestamps
    end
    add_index :posts, [:user_id,:created_at]

    create_table :relations do |t|
      t.integer :user_id
      t.integer :following_id
      t.timestamps
    end
    add_index :relations, :user_id
    add_index :relations, :following_id

  end
end
