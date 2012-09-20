module UsersHelper
  
  def correct_user_or_admin?
    current_user?(@user) || current_user.admin?
  end
  
  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_path) unless current_user?(@user)
  end
    
  def admin_user
    redirect_to(root_path) unless current_user.admin?
  end

  def correct_user_or_admin
    @user = User.find(params[:id])
    redirect_to(root_path) unless correct_user_or_admin?
  end
  
  def full_name(user)
    user.first_name + " " + user.last_name
  end
end
