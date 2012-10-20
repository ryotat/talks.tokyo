class AddLanguageToTalks < ActiveRecord::Migration
  def change
    add_column :talks, :language, :string
  end
end
