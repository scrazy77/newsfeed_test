# encoding: utf-8
require 'wave_box'
class User < ActiveRecord::Base
  has_many :posts
  has_many :relations
  has_many :followings, :through => :relations
  include ::WaveBox::GenerateWave
  include ::WaveBox::ReceiveWave
  can_generate_wave :name => "newsfeed",
                    :redis => :wave_redis_instance,
                    # waves with timestamp older than expire will be discarded
                    :expire => 60 * 60 * 24 * 365, # One year
                    # only store last 100 waves
                    :max_size => 100,
                    :id => :wave_box_id
  can_receive_wave :name => "newsfeed",
                   :redis => :wave_redis_instance,
                   :expire => 60 * 60 * 24 * 365, # One year
                   :max_size => 100,
                   :id => :wave_box_id
  def wave_redis_instance
    $redis
  end
  def wave_box_id
    self.id
  end
  def newsfeeds
    Post.where("id in (?)", received_newsfeed_after(0)).order("created_at DESC").limit(100)
  end
  def follow! user
    r = Relation.new
    r.user = self
    r.following_id = user.id
    r.save!
  end
end