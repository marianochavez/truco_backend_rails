class Game < ApplicationRecord
  has_many :players

  serialize :cards
  serialize :player_1
  serialize :player_2
  serialize :player_3
  serialize :player_4
  serialize :player_5
  serialize :player_6
  serialize :team_1
  serialize :team_2

  enum status: { Queue: 0, Playing: 1, Finished: 2, Abandoned: 3 }
  enum player_quantity: { Two: 2, Fourth: 4, Six: 6 }

  before_create :set_init_cards
  before_create :set_init_players

  include Filterable
  scope :filter_by_id, -> (id) { where id: id }
  scope :filter_by_status, -> (status) { where status: status }

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

  def create_game(username, pl_quantity)
    set_variables
    self.player_1 = { username: username, cards: [], played_cards: [] }
    self.round = 0
    self.player_quantity = pl_quantity
    self.team_1 = [nil]*(pl_quantity/2)
    self.team_2 = [nil]*(pl_quantity/2)
    self.team_1[0] = 'player_1'
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
    self[new_player] = { username: username, cards: [], played_cards: [] }
    check_join_players(@max_players)
  end

  def join_team(team)
    set_variables
    players = self.values_at(@players_list)
    new_player = @players_list[players.find_index(nil)]
    if team == 1
      unless self.team_1.include?(nil)
        return false
      end
      index = self.team_1.find_index(nil)
      self.team_1[index] = new_player
    else
      unless self.team_2.include?(nil)
        return false
      end
      index = self.team_2.find_index(nil)
      self.team_2[index] = new_player
    end

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
    # set full card deck
    set_init_cards
    @players_list.each { |player|
      # get 3 random cards from deck
      cards = self.cards.sample(3)
      self[player][:cards] = cards
      # delete selected cards from deck
      self.cards = self.cards.reject { |card| cards.include?(card) }
      self[player][:played_cards] = []
    }
  end

  def play(player, card)
    # delete card from cards (hand) & push to played cards
    self[player][:cards].delete(card)
    self[player][:played_cards].push(card)
  end

  def player_has_card?(player,card)
    self[player][:cards].include?(card)
  end

  def increment_round
    self.round += 1
  end

  def go_to_deck(player)
    self[player][:cards] = []
    self[player][:played_cards] = []
  end

  def burn_card(player,card)
    self[player][:cards].delete(card)
    self[player][:played_cards].push(nil)
  end

end
