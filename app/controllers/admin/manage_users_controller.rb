class Admin::ManageUsersController < ApplicationController
  before_action :authenticate_admin_admin!
  before_action :correct_user, only: [:show, :update]

  def index
    @users = User.order_by_time.page(params[:page]).per Settings.per_page
  end

  def show
    @reviews = @user.passive_reviews
  end

  def edit
  end

  def update
    if @user.update_attributes user_params_status
      flash[:success] = t "manage_users.update.success"
      binding.pry
    else
      flash[:danger] = t "manage_users.update.error"
    end
    redirect_to admin_path
  end

  private
  def user_params_status
    params.require(:user).permit :status
  end

  def correct_user
    @user = User.find_by id: params[:id]
    if @user.nil?
      flash[:danger] = t "users.messages.user_not_found"
      redirect_to admin_path
    end
  end
end
