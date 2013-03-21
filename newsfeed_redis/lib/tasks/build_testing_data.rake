# build pseudo data tasks
namespace :newsfeed  do
  desc "Newsfeed test"
  task :initdb => :environment do
    Newsfeed.initdb
    #BillingPeriod.compute_new_period
  end
  desc "Newsfeed benchmark"
  task :benchmark => :environment do
    Newsfeed.benchmark
  end
end


class Newsfeed
  @user_counts = 10000
  @followers_per_user = 100
  @post_per_user = 100
  def self.benchmark
    require 'benchmark'
    measurement = Benchmark.measure do
      1000.times do
        user_id = rand(1..@user_counts)
        user = User.find user_id
        user.newsfeeds
      end  
    end
    puts measurement
  end
  def self.initdb
    ActiveRecord::Base.transaction do
    puts "start create #{@user_counts} users\n"
    counter = 0
    users = []
    @user_counts.times do
      counter = counter + 1
      user = User.new
      user.name = Faker::Name.name
      users << user
      if counter%1000 == 0
        User.import users
        users = []
        print "#{counter*100/@user_counts}%\n "
        $stdout.flush
      end      
    end
    puts "\nsuccessfully create #{@user_counts} users\n"
    
    total_followers = @followers_per_user*@user_counts
    puts "start create #{total_followers} followers to random users\n"
    counter =0
    followers = []
    total_followers.times do
      counter = counter+1
      pair = User.random(2)
      user = pair[0]
      following = pair[1]
      user.follow! following
      r = Relation.new
      r.user = user
      r.following_id = following.id
      followers << r
      if counter%1000 == 0
        Relation.import followers
        followers = []
        print "#{counter*100/total_followers}%\n"
        $stdout.flush
      end
    end
    puts "\nsuccessfully create #{total_followers} followers to random users\n"
    end

    total_posts = @post_per_user*@user_counts
    counter = 0
    posts = []
    puts "start create #{total_posts} posts to random users\n"
    total_posts.times do
      counter = counter + 1
      post = Post.new
      post.title = Faker::Lorem.sentence(2)
      post.user = User.random(1).first
      #posts << post
      post.save
      if counter%100 == 0
        #Post.import posts
        #posts = []
        print "#{counter*100/total_posts}%\n"
        $stdout.flush
      end
      
    end
    puts "\nsuccessfully create #{total_posts} posts to random users\n"


  end
end