class AddUpdatedAtToDocumentVersions < ActiveRecord::Migration
  def change
    add_column :document_versions, :updated_at, :datetime

    add_index :document_versions, :updated_at
  end
end
