class Shop::ShippersController < Shop::ShopBaseController
  def index
    @shippers = if params[:type]
      current_user.send params[:type]
    else
      current_user.list_shipper_received
    end
    @shippers = search_advanced @shippers, params["search"] if params["search"]
    @shippers = @shippers.page(params[:page]).per Settings.per_list_shipper
    @supports = Supports::ShipperIndex.new params, @shippers.total_pages
    shippers_simple = Simples::Shipper::ShippersSimple.new object: @shippers.
      includes(:user_invoices, :user_setting), scope: {current_user: current_user}
    @shippers = shippers_simple.simple
    @current_type = params[:type].present? ? params[:type] : Settings.shipper.types.list_shipper_received
  end

  def update
    if params[:action_type] && current_user.send("#{params[:action_type]}", "#{params[:id]}")
      @shippers = current_user.send params[:current_type]
      shippers_simple = Simples::Shipper::ShippersSimple.new object: @shippers.
        includes(:user_invoices, :user_setting), scope: {current_user: current_user}
      @shippers = shippers_simple.simple
      @current_type = params[:current_type]
    end
  end

  private
  def search_advanced list_shipper, data
    if data["column"]
      list_shipper.where("#{data["type"]} like ?", "%#{data["query"]}%").order data["column"]
    else
      list_shipper.where("#{data["type"]} like ?", "%#{data["query"]}%")
    end
  end
end
