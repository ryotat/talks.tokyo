class AddDefaultLanguageAndMailingListAddressToLists < ActiveRecord::Migration
  def change
    add_column :lists, :default_language, :string
    add_column :lists, :mailing_list_address, :string
  end
end
