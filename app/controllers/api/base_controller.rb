class Api::BaseController < ActionController::API
  include Authenticable
  include Confirm
  include Notification
  acts_as_token_authentication_handler_for User, {fallback: :none}

  respond_to :json

  private
  def authenticate_user_from_token
    authenticate_with_token!
  end

  def ensure_params_exist
    missing_params = if params[:controller].present?
      name_controller = params[:controller].split("/").last.singularize
      true if params["#{name_controller}"].blank?
    else
      true
    end
    render json: {message: I18n.t("api.missing_params"), data: {}, code: 0},
      status: 422 if missing_params
  end

  def find_object
    object = params[:controller].split("/").last.singularize
    instance_variable_set("@#{object}", object.classify.constantize.find_by_id(params[:id]))
    unless instance_variable_get "@#{object}"
      render json: {message: I18n.t("#{object.pluralize}.messages.#{object}_not_found"),
        data: {}, code: 0}, status: 200
    end
  end
end
