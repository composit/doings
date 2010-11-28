class AddWorkableTypeToOfficeHours < ActiveRecord::Migration
  def self.up
    add_column :office_hours, :workable_type, :string
  end

  def self.down
    remove_column :office_hours, :workable_type
  end
end
