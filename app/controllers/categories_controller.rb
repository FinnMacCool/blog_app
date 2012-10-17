# Coding: UTF-8
class CategoriesController < ApplicationController
  before_filter :signed_in_user, only: [:new, :create, :edit, :update, :destroy]
  before_filter :admin_user, only: [:new, :create, :edit, :update, :destroy]
  
  
  def index
    @categories = Category.all
  end
  
  def show
    @category = Category.find(params[:id])
    @posts = @category.posts.paginate(page: params[:page], per_page: 5)
  end
  
  def new
    @category = Category.new
  end
  
  def edit
    @category = Category.find(params[:id])
  end
  
  def update
    @category = Category.find(params[:id])
    if @category.update_attributes(params[:category])
      flash[:success] = "Kategorie umbenannt"
      redirect_to @category
    else
      render 'edit'
    end
  end

  def create
    @category = Category.new(params[:category])
    if @category.save
      flash[:success] = "Kategorie #{@category.name} wurde erstellt."
      redirect_to @category
    else
      render 'new'
    end
  end

  def destroy
    Category.find(params[:id]).destroy
    flash[:success] = "Kategorie gelöscht."
    redirect_to categories_path
  end
end
