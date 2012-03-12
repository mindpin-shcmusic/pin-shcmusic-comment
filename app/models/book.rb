class Book < ActiveRecord::Base
  include Comment::CommentableMethods
  
  validates :name, :presence => true
end
