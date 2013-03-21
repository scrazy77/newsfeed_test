# encoding: utf-8
class Post < ActiveRecord::Base
  belongs_to :user
  after_save :push_to_followers
  def push_to_followers
    user.followings.each{|receiver|
        user.generate_newsfeed id, receiver
        #puts "receiver=#{receiver.id}, post=#{id}"
    }
  end 
end