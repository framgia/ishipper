class Shop::ShopBaseController < ApplicationController
  before_action :check_admin_signin
  before_action :authenticate_user!

  include ActionController::Serialization

  private
  def check_black_list
    black_user = @invoice.user_invoices - @invoice.user_invoices.init -
      @invoice.user_invoices.rejected
    unless black_user.blank?
      black_list = BlackList.find_by owner_id: current_user.id,
        black_list_user_id: black_user.first.user_id
      if black_list
        flash[:danger] = t "black_list.permission_denied"
        redirect_to root_path
      end
    end
  end
end
