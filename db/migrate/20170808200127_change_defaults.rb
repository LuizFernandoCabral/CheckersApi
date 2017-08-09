class ChangeDefaults < ActiveRecord::Migration[5.1]
  def change
  	change_column :games, :status, :string, :default => 'waiting for opponent'
    change_column :games, :board, :string, :default => '1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2,2'
  end
end
