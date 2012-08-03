class CreateListings < ActiveRecord::Migration
  def change
    create_table :listings do |t|
      t.float :latitude
      t.float :longitude
      t.datetime :completed_at
      t.integer :user_id

      t.timestamps
    end
  end
end
