class AuthsController < ApplicationController
  def show


  end

  def create
    api_base = 'https://api.clockify.me/api/v1'
    user_response = HTTParty.get("#{api_base}/user", headers: { 'X-Api-Key' => params[:api_key] })

    return redirect_to auth_path, danger: 'Invalid API key' unless user_response.ok?

    user = user_response.parsed_response

    session['user'] = user
    session['api_key'] = params['api_key']

    redirect_to times_path
  end
end
