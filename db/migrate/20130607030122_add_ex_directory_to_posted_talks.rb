class AddExDirectoryToPostedTalks < ActiveRecord::Migration
  def change
    add_column :posted_talks, :ex_directory, :boolean
  end
end
