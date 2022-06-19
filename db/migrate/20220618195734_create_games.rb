class CreateGames < ActiveRecord::Migration[7.0]
  def change
    create_table :games do |t|
      t.text :cards
      t.integer :status, default: 0
      t.integer :player_quantity, default: 2
      t.string :turn
      t.integer :round
      t.text :player_1
      t.text :player_2
      t.text :player_3
      t.text :player_4
      t.text :player_5
      t.text :player_6

      t.timestamps
    end
  end
end
