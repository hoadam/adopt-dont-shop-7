class Application < ApplicationRecord
  validates :name, presence: true
  validates :street_address, presence: true
  validates :city, presence: true
  validates :state, presence: true
  validates :zip_code, presence: true, numericality: true
  validates :description, presence: true

  enum status: {
    in_progress: 0,
    pending: 1,
    accepted: 2,
    rejected: 3
  }
  has_many  :application_pets
  has_many  :pets, through: :application_pets

  def submit_reason_for_adoption(reason)
    self.reason_for_adoption = reason
    self.status = "pending"
    self.save!
  end


end
