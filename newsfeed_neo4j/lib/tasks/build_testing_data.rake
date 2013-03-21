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
  @user_counts = 1000
  @followers_per_user = 100
  @post_per_user = 50
  @neo = Neography::Rest.new
  def self.benchmark
    require 'benchmark'
    measurement = Benchmark.measure do
      1000.times do
        user_id = rand(1..@user_counts)
        User.newsfeeds(user_id)
      end  
    end
    puts measurement
  end  
  def self.initdb
    @neo.create_node_index('users')
    @neo.create_node_index('posts')

    puts "start create #{@user_counts} users\n"
    counter = 0
    users = []
    @user_counts.times do
      counter = counter + 1
      user_id = counter
      user = Neography::Node.create("id" => user_id ,"name" => Faker::Name.name)
      @neo.add_node_to_index('users', 'id', user_id, user)
      if counter%1000 == 0
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
      counter = counter + 1
      user_id = rand(1..@user_counts)
      following_id = rand(1..@user_counts) 
      if following_id != user_id
        user = Neography::Node.find('users', 'id', user_id)
        following = Neography::Node.find('users', 'id', following_id)
        user.outgoing(:followings) << following
        if counter%1000 == 0
          print "#{counter*100/total_followers}%\n"
          $stdout.flush
        end
      end
    end
    puts "\nsuccessfully create #{total_followers} followers to random users\n"

    total_posts = @post_per_user*@user_counts
    counter = 0
    posts = []
    puts "start create #{total_posts} posts to random users\n"
    total_posts.times do
      counter = counter + 1
      post_id = counter
      user_id = rand(1..@user_counts)
      user = Neography::Node.find('users', 'id', user_id)
      post = Neography::Node.create("id" => post_id, "title" => Faker::Lorem.sentence(2), "created_at" => Time.now.to_i)
      @neo.add_node_to_index('posts', 'id', post_id, post)
      user.outgoing(:posts) << post
      if counter%1000 == 0
        print "#{counter*100/total_posts}%\n"
        $stdout.flush
      end      
    end
    puts "\nsuccessfully create #{total_posts} posts to random users\n"


  end
end