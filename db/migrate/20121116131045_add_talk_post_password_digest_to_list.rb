class AddTalkPostPasswordDigestToList < ActiveRecord::Migration
  def change
    add_column :lists, :talk_post_password_digest, :string
  end
end
