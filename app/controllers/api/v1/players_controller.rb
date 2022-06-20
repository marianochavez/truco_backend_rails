class Api::V1::PlayersController < ApplicationController
  before_action :set_player, only: [:sign_out]
  before_action :check_token, only: [:sign_out]

  def index
    players = Player.all
    render json: { status: 'OK', data: players }, status: :ok
  end

  def create
    player = Player.new(user_params)
    if player.save
      render json: { status: 'OK', data: player }, status: :created
    else
      render json: { status: 'ERROR', data: player.errors }, status: :unprocessable_entity
    end
  end

  def sign_in
    player = Player.find_by(username: params[:username])

    if player.present? && player.authenticate(params[:password])
      player.set_token
      player.save
      render json: { status: 'OK', data: player }, status: :ok
    else
      error = player.blank? ? 'Player does not exist' : 'Incorrect password'
      render json: { status: 'ERROR', data: error }, status: :bad_request
    end
  end

  def sign_out
    @player.set_token
    if @player.save
      render json: { status: 'OK' }, status: :ok
    else
      render json: { status: 'ERROR' }, status: :bad_request
    end
  end

  private

  def user_params
    params.permit(:name, :username, :password, :password_confirmation,)
  end
end
