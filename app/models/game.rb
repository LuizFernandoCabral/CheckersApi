class Game < ApplicationRecord
  before_create :randomize_id, :generate_tokens

  def check_and_update_winner
  	if self.board.include?("1") && !self.board.include?("2")
  		self.status = 'player_1_won'
  	elsif self.board.include?("2") && !self.board.include?("1")
  		self.status = 'player_2_won'
  	end	
  end

  def is_valid_token?(player, token)
  	if player == 'one'
      return self.player1Token == token 
    else
      return self.player2Token == token
    end
  end

  def join?(access_token)
    return game_is_waiting? &&
      is_valid_access_token?(access_token) && 
      self.update("status" => "player_1 turn", 
        "accessToken" => generate_rand_token)
  end

  def moves_at(pos, player)
  	destinations = Array.new
  	if pos_is_empty?(pos)
  	  return destinations
  	end

  	destinations.push(*get_simple_destinations(player, pos))
  	destinations.push(*get_jump_destinations(player, pos))
  end

  def move(from, to, player)
  	board_as_array = self.board.split(",")
  	board_as_array[from-1] = "0"

  	if player == 'one'
  	  board_as_array[to-1] = "1"
  	elsif player == 'two'
  	  board_as_array[to-1] = "2"
  	end

  	diff = to - from
  	if diff.abs > 5
  	  board_as_array[get_enemy(from, to)-1] = "0"
  	end

  	self.update("board" => board_as_array.join(','))
  end

  private
  def randomize_id
    begin
      self.id = SecureRandom.random_number(1_000_000)
    end while Game.where(id: self.id).exists?
  end

  def generate_tokens
    self.accessToken = generate_rand_token 
    self.player1Token = generate_rand_token
    self.player2Token = generate_rand_token
  end

  def generate_rand_token
    return SecureRandom.urlsafe_base64(nil,false)
  end

  def is_valid_access_token?(token)
    return self.accessToken == token
  end

  def game_is_waiting?
    return self.status.include? "waiting"
  end

  def pos_is_empty?(pos)
	board_as_array = self.board.split(",")
	return board_as_array[pos-1] == '0'
  end

  def get_simple_destinations(player, pos)
  	simple_destinations = Array.new
  	full_moves_map = get_moves_map

  	full_moves_map[pos].each do |dst|
  	  if allowed_move(player, pos, dst)
  	  	simple_destinations.push(dst)
  	  end
  	end
  	return simple_destinations
  end

  def get_moves_map
    return moves_map = {
      1=>[5,6],2=>[6,7],3=>[7,8],4=>[8],
      5=>[1,9],6=>[1,2,9,10],7=>[2,3,10,11],8=>[3,4,11,12],
      9=>[5,6,13,14],10=>[6,7,14,15],11=>[7,8,15,16],12=>[8,16],
      13=>[9,17],14=>[9,10,17,18],15=>[10,11,18,19],16=>[11,12,19,20],
      17=>[13,14,21,22],18=>[14,15,22,23],19=>[15,16,23,24],20=>[16,24],
      21=>[17,25],22=>[17,18,25,26],23=>[18,19,26,27],24=>[19,20,27,28],
      25=>[21,22,29,30],26=>[22,23,30,31],27=>[23,24,31,32],28=>[24,32],
      29=>[25],30=>[25,26],31=>[26,27],32=>[27,28]
    }
  end

  def allowed_move(player, from, to)
  	empty = pos_is_empty?(to)
  	rigth_dst_row = ((player == 'one' && from < to) || (player == 'two' && from > to))
  	return rigth_dst_row && empty
  end

  def get_jump_destinations(player, pos)
  	jump_destinations = Array.new
  	full_jump_map = get_jump_map

  	full_jump_map[pos].each do |dst|
  	  if allowed_jump(player,pos, dst)
  	  	jump_destinations.push(dst)
  	  end
  	end
  	return jump_destinations
  end

  def get_jump_map
    return jumps_map = {
      1=>[10],2=>[9,11],3=>[10,12],4=>[11],
      5=>[14],6=>[13,15],7=>[14,16],8=>[15],
      9=>[2,18],10=>[1,3,17,19],11=>[2,4,18,20],12=>[3,19],
      13=>[6,22],14=>[5,7,21,23],15=>[6,8,22,24],16=>[7,23],
      17=>[10,26],18=>[9,11,25,27],19=>[10,12,26,28],20=>[11,27],
      21=>[14,30],22=>[13,15,29,31],23=>[14,16,30,32],24=>[15,31],
      25=>[18],26=>[17,19],27=>[18,20],28=>[19],
      29=>[22],30=>[21,23],31=>[22,24],32=>[23]
    }
  end

  def allowed_jump(player, from, to)
  	empty = pos_is_empty?(to)
  	rigth_dst_row = ((player == 'one' && from < to) || (player == 'two' && from > to))
  	enemy = is_there_enemy(player, from, to)
  	return empty && rigth_dst_row && enemy
  end

  def is_there_enemy(player, from, to)
	board_as_array = self.board.split(",")
	two_is_enemy = (player == 'one') && board_as_array[get_enemy(from, to)-1] == '2'
	one_is_enemy = (player == 'two') && board_as_array[get_enemy(from, to)-1] == '1'
	return two_is_enemy || one_is_enemy
  end

  def get_enemy(from, to)
  	diff = to - from
  	row = index_to_row(from)
  	if diff == 7
  	  return row.even? ? from+3 : from+4
  	elsif diff == 9
  	  return row.even? ? from+4 : from+5
  	elsif diff == -7
  	  return row.even? ? from-4 : from-3
  	elsif diff == -9
  	  return row.even? ? from-5 : from-4
    else
      return nil
  	end
  end

  def index_to_row(index)
  	return ((index-1)/4) + 1
  end
end
