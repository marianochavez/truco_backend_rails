class Game < ApplicationRecord
  #todo lo tengo que poner al hasmany? al tener players, en que me infiere si tengo el att players
  has_many :players

  enum state: {Queue: 0, Playing: 1, Finished: 2, Abandoned: 3}
  enum player_quantity: { Two: 2, Fourth: 4, Six: 6}
  serialize :cards
  before_create :set_cards

  def set_cards
    self.cards = (['e', 'c', 'o', 'b'].map {
      |suit| [1, 2, 3, 4, 5, 6, 7, 10, 11, 12].map { |number| number.to_s + suit } }).flatten
  end

  serialize :players


end
