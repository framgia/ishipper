class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  include CanCan::ControllerAdditions

  rescue_from CanCan::AccessDenied do |exception|
    flash[:danger] = exception.message
    redirect_to root_path
  end

  private
  def find_object
    object = params[:controller].split("/").last.singularize
    instance_variable_set("@#{object}", object.classify.constantize.find_by_id(params[:id]))
    unless instance_variable_get "@#{object}"
      flash[:danger] = t "#{object.pluralize}.messages.#{object}_not_found"
      redirect_to root_path
    end
  end

  def current_ability
    controller_name_segments = params[:controller].split('/')
    controller_name_segments.pop
    controller_namespace = controller_name_segments.join('/').camelize
    Ability.new current_user, controller_namespace
  end

  def layout_by_user
    if admin_admin_signed_in?
      redirect_to "/admin"
    elsif user_signed_in?
      redirect_to root_path
    else
    end
  end

  def check_admin_signin
    if admin_admin_signed_in?
      redirect_to admin_path
    end
  end
end
