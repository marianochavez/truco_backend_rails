class Game < ApplicationRecord
  #todo lo tengo que poner al hasmany? al tener players, en que me infiere si tengo el att players
  has_many :players

  serialize :cards
  serialize :player_1
  serialize :player_2
  serialize :player_3
  serialize :player_4
  serialize :player_5
  serialize :player_6

  enum status: { Queue: 0, Playing: 1, Finished: 2, Abandoned: 3 }
  enum player_quantity: { Two: 2, Fourth: 4, Six: 6 }

  before_create :set_init_cards
  before_create :set_init_players

  def set_init_cards
    self.cards = (%w[e c o b].map {
      |suit| [1, 2, 3, 4, 5, 6, 7, 10, 11, 12].map { |number| number.to_s + suit } }).flatten
  end

  def set_init_players
    self.player_2 = nil
    self.player_3 = nil
    self.player_4 = nil
    self.player_5 = nil
    self.player_6 = nil
  end

  def set_variables
    @max_players = Game.player_quantities[self.player_quantity].to_i
    @players_list = %w[player_1 player_2 player_3 player_4 player_5 player_6].slice(0, @max_players)
  end

  def create_game(username)
    self.player_1 = { username: username, cards: [nil] * 3 }
    self.round = 1
  end

  def check_username(username)
    set_variables
    players = self.values_at(@players_list)
    usernames = players.map { |player| player.present? ? player[:username] : '' }
    usernames.include?(username)
  end

  def has_space?(pos)
    set_variables
    players = self.values_at(@players_list)
    players_pos = players.slice(0, pos)
    players_pos.include?(nil)
  end

  def can_join?(username)
    set_variables
    check_username(username) ? false : has_space?(@max_players)
  end

  def join_game(username)
    set_variables
    players = self.values_at(@players_list)
    new_player = @players_list[players.find_index(nil)]
    self[new_player] = { username: username, cards: [nil] * 3 }
    check_join_players(@max_players)
  end

  def check_join_players(num)
    unless has_space?(num)
      self.status = 1
    end
  end

  def set_status(status)
    self.status = status
  end

  def deal_cards
    set_variables
    @players_list.each { |player|
      cards = self.cards.sample(3)
      self[player][:cards] = cards
      self.cards = self.cards.reject {|card| cards.include?(card)}
    }
  end

end
