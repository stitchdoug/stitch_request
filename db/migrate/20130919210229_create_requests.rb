class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.integer :stitch_id

      t.timestamps
    end
  end
end
