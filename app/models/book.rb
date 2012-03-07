class Book < ActiveRecord::Base
  has_many :comments,:as=>:model
  
  validates :name, :presence => true
end
