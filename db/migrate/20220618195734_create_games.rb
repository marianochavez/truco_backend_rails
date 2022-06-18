class CreateGames < ActiveRecord::Migration[7.0]
  def change
    create_table :games do |t|
      t.text :cards
      t.integer :status, default: 0
      t.integer :player_quantity, default: 2
      t.string :turn
      t.integer :round
      t.text :players

      t.timestamps
    end
  end
end
