class SessionsController < ApplicationController
  
  def new
  end

  def create
    user = User.find_by_email(params[:email].downcase)
    if user && user.authenticate(params[:password])
      log_in user
      redirect_back_or root_url
    else
      flash.now[:error] = 'E-Mail-Adresse und/oder Passwort falsch'
      render 'new'
    end
  end

  def destroy
    log_out
    redirect_to root_url
  end
end
