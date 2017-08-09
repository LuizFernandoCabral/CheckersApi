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
  end

  def status
    @game = Game.find(params[:game_id])
      
    if !@game.is_valid_token(params[:status_token_validation][:player_token])
      flash.now[:notice] = 'Invalid token for this game!'
      render 'helperForms'
    end
  end

  def join
    @game = Game.find(params[:game_id])

    if !@game.join(params[:player_2_join][:access_token])
      flash.now[:notice] = 'Invalid token, or game already full!'
      render 'helperForms'
    end
  end

end
