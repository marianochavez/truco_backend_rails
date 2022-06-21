class Api::V1::GamesController < ApplicationController
  before_action :set_player, only: [:show, :create, :join_game, :leave, :deal, :play_card]
  before_action :check_token, only: [:show, :create, :join_game, :leave, :deal, :play_card]
  before_action :set_game, only: [:show, :join_game, :leave, :deal, :play_card]
  before_action :check_player_in, only: [:show,:leave, :deal, :play_card]
  before_action :check_player_play, only: [:play_card]
  before_action :check_state, only: [:show,:join_game, :leave, :deal, :play_card]

  def index
    games = Game.filter(params.slice(:id, :status, :player))
    render json: { status: 'OK', data: games }, status: :ok
  end

  def show
    render json: { status: 'OK', data: @game }, status: :ok
  end

  def create
    unless Game.player_quantities.values.include?(params[:player_quantity])
      return render json: { status: 'ERROR', data: "The number of players can be 2,4,6" }, status: :bad_request
    end
    game = Game.new
    game.create_game(@player["username"], params[:player_quantity])
    if game.save
      render json: { status: 'OK', data: game }, status: :ok
    else
      render json: { status: 'ERROR', data: game.errors }, status: :bad_request
    end
  end

  def join_game
    unless @game.can_join?(@player['username'])
      return render json: { status: 'ERROR', data: 'Not possible to join' }, status: :ok
    end

    @game.join_game(@player['username'])
    if @game.save
      render json: { status: 'OK', data: @game }, status: :ok
    else
      render json: { status: 'ERROR', data: @game.errors }, status: :unprocessable_entity
    end
  end

  def leave
    @game.set_status(3)
    if @game.save
      render json: { status: 'OK', data: @game }, status: :ok
    end
  end

  def deal
    @game.deal_cards
    @game.increment_round
    if @game.save
      render json: { status: 'OK', data: @game }, status: :ok
    else
      render json: { status: 'ERROR', data: @game.errors }, status: :unprocessable_entity
    end
  end

  def play_card
    unless @game.player_has_card?(params[:player],params[:card])
      return render json: { status: 'ERROR', data: 'The player does not have the card or it is played' }, status: :ok
    end

    @game.play(params[:player],params[:card])
    if @game.save
      render json: { status: 'OK', data: @game }, status: :ok
    else
      render json: { status: 'ERROR', data: @game.errors }, status: :unprocessable_entity
    end
  end

  private

  def set_game
    @game = Game.find(params[:id])
    return if @game.present?

    render json: { status: 'ERROR', data: "Game not found" }, status: :not_found
    false
  end

  def check_state
    return if @game.status != "Finished" || @game.status != "Abandoned"

    render json: { status: 'ERROR', data: "The game is over, create a new one" }, status: :ok
  end

  def check_player_in
    return if @game.check_username(@player['username'])

    render json: { status: 'ERROR', data: 'Unauthorized' }, status: :unauthorized
  end

  def check_player_play
    return if @game[params[:player]][:username] == @player['username']

    render json: { status: 'ERROR', data: 'Unauthorized' }, status: :unauthorized
  end
end
