class CreateCalls < ActiveRecord::Migration[5.1]
  def change
    create_table :calls do |t|
      t.string :callsid
      t.string :caller
      t.string :called
      t.string :status
      t.integer :duration
      t.string :url

      t.timestamps
    end
  end
end
