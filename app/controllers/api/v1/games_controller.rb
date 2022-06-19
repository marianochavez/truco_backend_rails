class Api::V1::GamesController < ApplicationController
  before_action :set_player, only: [:create, :join_game]
  before_action :check_token, only: [:create, :join_game]
  before_action :set_game, only: [:show, :join_game]
  before_action :check_state, only: [:join_game]

  def index
    games = Game.all
    render json: { data: games }, status: :ok
  end

  def show
    render json: { data: @game }, status: :ok
  end

  def create
    game = Game.new
    game.create_game(@player["username"])
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

  private

  def set_game
    @game = Game.find(params[:id])
    return if @game.present?

    render json: { data: "Game not found" }, status: :not_found
    false
  end

  def check_state
    return if @game.status != "Finished" || @game.status != "Abandoned"

    render json: { data: "The game is over, create a new one" }, status: :ok
  end
end
