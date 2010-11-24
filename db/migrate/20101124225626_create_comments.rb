class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.integer :commentable_id
      t.integer :commenter_id
      t.text :content

      t.timestamps
    end
  end

  def self.down
    drop_table :comments
  end
end
