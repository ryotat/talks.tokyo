class CreatePostedTalks < ActiveRecord::Migration
  def change
    create_table :posted_talks do |t|
      t.string :title
      t.text :abstract
      t.datetime :start_time
      t.datetime :end_time
      t.string :name_of_speaker
      t.string :speaker_email
      t.string :sender_ip
      t.integer :speaker_id
      t.integer :series_id
      t.integer :venue_id
      t.text :abstract_filtered
      t.string :language

      t.timestamps
    end
  end
end
