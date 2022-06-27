class Player < ApplicationRecord
  has_many :games

  has_secure_password
  validates :username, presence: true, uniqueness: true
  validates :password, length: { minimum: 6, maximum: 20 }, on: :create
  validates :name, presence: true
  validates :token, uniqueness: true

  before_create :set_token

  include Filterable
  scope :filter_by_username, -> (username) {where username: username}

  def set_token
    self.token = SecureRandom.uuid
  end

  def set_avatar(url)
    self.avatar = url
  end
end
