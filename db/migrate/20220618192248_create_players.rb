class CreatePlayers < ActiveRecord::Migration[7.0]
  def change
    create_table :players do |t|
      t.string :username
      t.string :name
      t.string :password_digest
      t.string :token

      t.timestamps
    end
  end
end
