class GamesController < ApplicationController
  def index
    @games = Game.all
  end

  def create
    @game = Game.new

    if @game.save
      redirect_to @game
    else
      render 'new'
    end
  end

  def show
  	@game = Game.find(params[:id])
    render :json => {:Game => @game.id, 
    	"player_token" => @game.player1Token,
    	"access_token" => @game.accessToken,
    	:board => @game.board}
  end

  def status
    @game = Game.find(params[:game_id])
    player = params[:status_token_validation][:player]
    token = params[:status_token_validation][:player_token]
      
    @game.check_and_update_winner

    if @game.is_valid_token?(player, token)
      render :json => {:Game => @game.id, :status => @game.status}
    else
      flash.now[:notice] = "Invalid token for player #{player}!"
      render 'helperForms'
    end
  end

  def join
    @game = Game.find(params[:game_id])
    token = params[:player_2_join][:access_token]

    if @game.join?(token)
      render :json => {:Game => @game.id, :player_token => @game.player2Token}
    else
      flash.now[:notice] = "Invalid token, or game already full!"
      render 'helperForms'
    end
  end

  def check_moves
  	@game = Game.find(params[:game_id])
    player = params[:check_moves][:player]
  	token = params[:check_moves][:player_token]

  	row = Integer(params[:check_moves][:row])-1
  	col = Integer(params[:check_moves][:col])+1

  	if @game.is_valid_token?(player, token)
	  pos = input_to_pos(row, col)
	  output_dst = Array.new
	  destinations = @game.moves_at(pos, player)
	  destinations.each do |dst|
	  	output_dst.push(pos_to_output(dst))
	  end
	  if output_dst.size == 0
	  	output_dst.push("NO ALLOWED MOVES")
	  end
	  render :json => {:Game => @game.id, :allowed_moves => output_dst.join(', ')}
	else
	  flash.now[:notice] = "Invalid token for player #{player}!"
      render 'helperForms'
    end
  end

  def move
  	@game = Game.find(params[:game_id])
    player = params[:move][:player]
  	token = params[:move][:player_token]

  	from_row = Integer(params[:move][:from_row])-1
  	from_col = Integer(params[:move][:from_col])+1

  	to_row = Integer(params[:move][:to_row])-1
  	to_col = Integer(params[:move][:to_col])+1

  	if @game.is_valid_token?(player, token)
	  from_pos = input_to_pos(from_row, from_col)
	  to_pos = input_to_pos(to_row, to_col)
	  allowed_moves = @game.moves_at(from_pos, player)
	  if allowed_moves.include?(to_pos)
	  	@game.move(from_pos, to_pos, player)
	  end
	  render :json => {:Game => @game.id, :board => @game.board}
	else
	  flash.now[:notice] = "Invalid token for player #{player}!"
      render 'helperForms'
    end
  end

  private
  def input_to_pos(row, col)
  	return ((row * 4) + (col / 2))
  end

  def pos_to_output(pos)
  	row = ((pos-1)/4)+1
  	col = pos%4
  	if col==0
  	  col=4
  	end
  	col *= 2
  	if row.even?
  	  col-=1
  	end
  	return "(#{row})(#{col})"
  end
end
