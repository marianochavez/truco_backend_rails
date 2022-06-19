class ApplicationController < ActionController::API
  def set_player
    @player ||= Player.find_by(token: header_token)
    return if @player.present?

    render json: { error: 'Player not found' }, status: :not_found
  end

  def header_token
    if request.headers['Authorization'].present?
      request.headers['Authorization'].split(' ').last
    else
      nil
    end
  end

  def check_token
    return if header_token.present? && header_token == @player.token

    render json: { error: 'Token error' }, status: :unauthorized
  end
end
