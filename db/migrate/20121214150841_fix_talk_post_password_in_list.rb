class FixTalkPostPasswordInList < ActiveRecord::Migration
  def change
    rename_column :lists, :talk_post_password_digest, :talk_post_password
  end
end
