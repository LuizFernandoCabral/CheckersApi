class CreateGames < ActiveRecord::Migration[5.1]
  def change
    create_table :games do |t|

    	t.string :accessToken
    	t.string :player1Token
    	t.string :player2token

    	t.string :status
    	t.string :board

      t.timestamps
    end
  end
end
