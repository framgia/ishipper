class PagesController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :after_admin_signed_in, only: :index

  def index
    @feed_back = FeedBack.new
  end

  def show
    @feed_back = FeedBack.new
    render template: "pages/#{params[:page]}"
  end

  private
  def after_admin_signed_in
    if user_signed_in?
      if current_user.admin?
        redirect_to admin_root_path
      elsif current_user.shop?
        redirect_to shop_root_path
      end
    end
  end
end
