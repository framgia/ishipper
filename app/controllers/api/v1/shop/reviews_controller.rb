class Api::V1::Shop::ReviewsController < Api::ShopBaseController
  before_action :ensure_params_true, :find_shipper

  def index
    @reviews = @shipper.passive_reviews
    review_simple = Simples::ReviewsSimple.new object: @reviews
    @review_simple = review_simple.simple
    render json: {message: I18n.t("review.success"), data: {reviews: @review_simple},
      code: 1}, status: 200
  end

  private
  def ensure_params_true
    check_params = CheckParams.new attributes_params: Review::REVIEW_ATTRIBUTES_PARAMS,
      params: params[:review]
    unless check_params.perform?
      render json: {message: I18n.t("review.missing_params"), data: {}, code: 0},
        status: 422
    end
  end

  def find_shipper
    @shipper = Shipper.find_by id: params[:review][:recipient_id]
    unless @shipper
      render json: {message: I18n.t("shipper_not_found"), data: {}, code: 0}, status: 200
    end
  end
end
