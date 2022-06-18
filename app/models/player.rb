class Player < ApplicationRecord
  has_many :games

  has_secure_password
  validates :username, presence: true, uniqueness: true
  validates :name, presence: true
  validates :token, uniqueness: true

  before_create :set_token

  def set_token
    self.token = SecureRandom.uuid
  end
end
