# Coding: UTF-8
class PostsController < ApplicationController
  before_filter :signed_in_user, only: [:new, :create, :edit, :update, :destroy]
  before_filter :authorized_user, only: [:edit, :update, :destroy]
  
  def index
    @posts = Post.search(params[:search_tags]).paginate(page: params[:page], per_page: 5)
  end

  def show
    @post = Post.find(params[:id])
  end

  def new
    @post = Post.new
  end

  def create
    @post = current_user.posts.build(params[:post])
    if @post.save
      flash[:success] = "Eintrag wurde erstellt."
      redirect_to @post
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @post.update_attributes(params[:post])
      flash[:success] = "Änderungen gespeichert"
      redirect_to @post
    else
      render 'edit'
    end
  end

  def destroy
    Post.find(params[:id]).destroy
    flash[:success] = "Eintrag gelöscht."
    redirect_to(root_path)
  end
  
  private
  
  def authorized_user
    @post = Post.find(params[:id])
    @user = User.find(@post.author_id)
    redirect_to(root_path) unless correct_user_or_admin?
  end
end
