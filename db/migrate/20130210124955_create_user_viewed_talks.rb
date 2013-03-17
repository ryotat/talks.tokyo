class CreateUserViewedTalks < ActiveRecord::Migration
  def change
    create_table :user_viewed_talks do |t|
      t.integer :user_id
      t.integer :talk_id
      t.datetime :last_seen

    end

    add_index :user_viewed_talks, :user_id
    add_index :user_viewed_talks, :talk_id
    add_index :user_viewed_talks, :last_seen
    add_index :user_viewed_talks, [:user_id, :talk_id], unique:true
  end
end
