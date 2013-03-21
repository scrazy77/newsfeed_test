# encoding: utf-8
class User < ActiveRecord::Base
  has_many :posts
  has_many :relations
  has_many :reverse_relations
  has_many :followings, :through => :relations
  #has_many :followings, :through => :reverse_relations
#followings.pluck(:following_id)
  def newsfeeds
    Post.where("user_id in (?)", followings.pluck(:following_id)).order("created_at DESC").limit(100)
  end
  def follow! user
    r = Relation.new
    r.user = self
    r.following_id = user.id
    r.save!
  end
end