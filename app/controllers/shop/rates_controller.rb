class Shop::RatesController < ApplicationController
  before_action :find_invoice, :find_user_invoice, except: :destroy
  before_action :find_rate, except: :create

  def create
    @rate = current_user.reviews.build rate_params
    unless @rate.save
      flash.now[:danger] = t "rate.create_fail"
    end
    redirect_to :back
  end

  def update
    unless @rate.update_attributes rate_params
      flash.now[:danger] = t "rate.update.fails"
    end
    redirect_to :back
  end

  def destroy
    unless current_user == @rate.owner && @rate.destroy
      flash.now[:danger] = t "rate.delete.fails"
    end
    redirect_to :back
  end

  private
  def rate_params
    params.require(:rate).permit Review::RATE_ATTRIBUTES_PARAMS
  end

  def find_rate
    @rate = Review.find_by :id params[:id]
    if @rate.nil?
      flash.now[:danger] = t "rate.not_found"
      redirect_to :back
    end
  end

  def find_invoice
    @invoice = Invoice.find_by :id params[:rate][:invoice_id]
    if @invoice.nil?
      flash.now[:danger] = t "rate.invoice.get_invoice_fail"
      redirect_to root_url
    end
  end

  def find_user_invoice
    status = @invoice.status
    @user_invoice = @invoice.user_invoices.find_by_status status
    if @user_invoice.nil?
      flash.now[:danger] = t "rate.invoice.get_user_invoice_fail"
      redirect_to root_url
    end
  end
end
