class Relation < ActiveRecord::Base
  belongs_to :user
  belongs_to :following, :class_name => 'User'
  
end

