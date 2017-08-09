class RenameColumn < ActiveRecord::Migration[5.1]
  def change
  	rename_column :games, :player2token, :player2Token
  end
end
