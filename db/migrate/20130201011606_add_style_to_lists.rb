class AddStyleToLists < ActiveRecord::Migration
  def change
    add_column :lists, :style, :string
  end
end
