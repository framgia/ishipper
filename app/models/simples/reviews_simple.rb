class Simples::ReviewsSimple < Simples::BaseSimple
  attr_accessor :id, :owner_id, :recipient_id, :invoice_id, :review_type, :rating_point,
    :content, :date

  def date
    Time.at(@object.created_at).strftime Settings.date_format
  end
end
