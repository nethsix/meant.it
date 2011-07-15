class EntityDatum < ActiveRecord::Base
#  validates :email, :presence => true
  validates :dob_yyyy, :length => { :is => 4 }, :allow_nil => true
  validates :dob_mm, :length => { :is => 2 }, :inclusion => { :in => 1..12 }, :allow_nil => true
  validates :dob_dd, :length => { :is => 2 }, :allow_nil => true
  validates :credit_card_no_1, :length => { :is => 4 }, :allow_nil => true
  validates :credit_card_no_2, :length => { :is => 4 }, :allow_nil => true
  validates :credit_card_no_3, :length => { :is => 4 }, :allow_nil => true
  validates :credit_card_no_4, :length => { :is => 4 }, :allow_nil => true
  validates :credit_card_exp_yyyy, :length => { :is => 4 }, :allow_nil => true
  validates :credit_card_exp_mm, :length => { :is => 2 }, :allow_nil => true
  validates :credit_card_ccv, :length => { :is => 3 }, :allow_nil => true
end
