# Coding: UTF-8
class UsersController < ApplicationController
  before_filter :signed_in_user, only: [:index, :show, :new, :create, :edit, :update, :destroy]
  before_filter :correct_user_or_admin, only: [:edit, :update]
  before_filter :admin_user, only: [:new, :create, :destroy]
  
  def index
    @users = User.all
  end
  
  def show
    @user = User.find(params[:id])
  end
  
  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:success] = "Neuer User wurde erstellt."
      redirect_to "/user/#{@user.id}/anzeigen"
    else
      render 'new'
    end
  end
  
  def edit
    
  end
  
  def update
    if @user.update_attributes(params[:user])
      flash[:success] = "Änderungen gespeichert"
      redirect_to @user
    else
      render 'edit'
    end
    
  end

  def destroy
    doomed_user = User.find(params[:id])
    if doomed_user == current_user
      flash[:failure] = "Der Admin kann sich nicht selbst löschen."
      redirect_to users_url
    else
      doomed_user.destroy
      flash[:success] = "User gelöscht."
      redirect_to users_url
    end
  end
  
end