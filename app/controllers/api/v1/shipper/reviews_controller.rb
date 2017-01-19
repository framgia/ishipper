class Api::V1::Shipper::ReviewsController < Api::ShipperBaseController
  before_action :ensure_params_true, :find_shop

  def index
    @reviews = @shop.passive_reviews
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

  def find_shop
    @shop = Shop.find_by id: params[:review][:recipient_id]
    unless @shop
      render json: {message: I18n.t("shop_not_found"), data: {}, code: 0}, status: 200
    end
  end
end
