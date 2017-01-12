class Supports::Shipper::Shipper < Supports::User
  def initialize args
    @current_user = args[:current_user]
    @shipper = args[:shipper]
    @invoice = args[:invoice]
  end

  def favorite_user
    @favorite_user ||= if @current_user.owner_favorite_lists.
      find_by(favorite_list_user_id: @shipper.id).present?
      "favorite_user"
    elsif @current_user.owner_black_lists.find_by(black_list_user_id: @shipper.id).present?
      "black_user"
    else
      "shipper"
    end
  end

  def actions
    actions = Settings.shipper.actions.to_h
    if favorite_user == "favorite_user"
      actions.slice :add_to_black_list, :remove_from_favorite_list
    elsif favorite_user == "black_user"
      actions.slice :remove_from_black_list
    elsif favorite_user == "shipper"
      actions.slice :add_to_favorite_list, :add_to_black_list
    end
  end

  def number_finished_invoice
    @shipper.user_invoices.finished.size
  end

  def number_all_invoice
    @shipper.user_invoices.reject{|invoice| invoice.rejected?}.size
  end

  def user_invoice_id
    user_invoice = @shipper.user_invoices.find{|user_invoice|
      user_invoice.invoice_id == @invoice.id}
    if user_invoice
      user_invoice.id
    else
      0
    end
  end
end
