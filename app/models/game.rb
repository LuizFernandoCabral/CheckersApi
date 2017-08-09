class Game < ApplicationRecord
  before_create :randomize_id, :generate_tokens

  def is_valid_token(token)
    return self.player1Token == token || self.player2Token == token
  end

  def join(access_token)
    return game_is_waiting &&
      is_valid_access_token(access_token) && 
      self.update("status" => "player_1 turn", 
        "accessToken" => generate_rand_token)
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

  def is_valid_access_token(token)
    return self.accessToken == token
  end

  def game_is_waiting
    return self.status.include? "waiting"
  end
end
