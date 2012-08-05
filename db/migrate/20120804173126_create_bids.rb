class CreateBids < ActiveRecord::Migration
  def change
    create_table :bids do |t|
      t.integer :user_id
      t.integer :listing_id
      t.decimal :bid_amount
      t.float :x
      t.float :y
      t.float :width
      t.float :height

      t.timestamps
    end
  end
end
