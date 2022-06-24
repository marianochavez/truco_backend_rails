class Api::V1::PlayersController < ApplicationController
  before_action :set_player, only: [:sign_out, :avatar]
  before_action :check_token, only: [:sign_out, :avatar]
  before_action :check_configuration, only: [:create, :avatar]

  def index
    players = Player.all
    render json: { status: 'OK', data: players }, status: :ok
  end

  def create
    player = Player.new(user_params)
    upload_image
    player.set_avatar(@image_url)
    if player.save
      render json: { status: 'OK', data: player }, status: :created
    else
      render json: { status: 'ERROR', data: player.errors }, status: :unprocessable_entity
    end
  end

  def avatar
    upload_image
    unless params[:avatar]
      return render json: { status: 'ERROR', data: 'No image uploaded' }, status: :bad_request
    end
    @player.set_avatar(@image_url)

    if @player.save
      render json: { status: 'OK', data: @player }, status: :created
    else
      render json: { status: 'ERROR', data: @player.errors }, status: :unprocessable_entity
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
    params.permit(:name, :username, :avatar, :password, :password_confirmation,)
  end

  def check_configuration
    render json: { status: 'ERROR', data: 'Cloudinary configuration missing' } if Cloudinary.config.api_key.blank?
  end

  def upload_image
    @default_image = 'https://res.cloudinary.com/chavedo/image/upload/v1656087237/truco_profiles/default.png'
    if params[:avatar]
      image_res = Cloudinary::Uploader.upload(params[:avatar],
                                              :folder => 'truco_profiles/',
                                              :overwrite => 'true',
                                              :public_id => params[:username] ? params[:username] : @player['username'],
                                              :width => 500, :height => 500, :crop => 'fill')
      return @image_url = image_res['secure_url'] ? image_res['secure_url'] : @default_image
    end

    @image_url = @default_image
  end

end
