class ApplicationController < ActionController::Base
  helper_method :current_user, :api_key

  def authenticate_user
    if !current_user || !api_key
      redirect_to auth_path, notice: 'Add your Clockify API key to proceed'
    end
  end

  def current_user
    session[:user]
  end

  def api_key
    session[:api_key]
  end
end
