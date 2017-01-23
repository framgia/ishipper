class Review < ApplicationRecord
  belongs_to :owner, class_name: User.name
  belongs_to :recipient, class_name: User.name
  belongs_to :invoice

  enum review_type: [:rate, :report]

  RATE_ATTRIBUTES_PARAMS = [:rating_point, :content]
  REPORT_ATTRIBUTES_PARAMS = [:content]
  REVIEW_ATTRIBUTES_PARAMS = [:recipient_id]

  scope :report_in_day, -> {where "created_at >=?", Time.zone.now - 1.day}
  scope :reviews
end
