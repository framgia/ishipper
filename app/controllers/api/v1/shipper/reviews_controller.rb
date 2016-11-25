class Api::V1::Shipper::ReviewsController < Api::ShipperBaseController
  before_action :ensure_params_true

  def index
    @reviews = Review.find_by_recipient_id params[:review][:recipient_id]
    render json: {message: I18n.t("review.success"), data: {review: @reviews},
      code: 1}, status: 200
  end

  private
  def ensure_params_true
    unless CheckParams.new(attributes_params: Review::REVIEW_ATTRIBUTES_PARAMS,
      params: params[:review]).perform?
      render json: {message: I18n.t("review.missing_params"), data: {}, code: 0},
        status: 422
    end
  end
end
