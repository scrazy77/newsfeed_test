# encoding: utf-8
module User
  @neo = Neography::Rest.new
  def self.newsfeeds(user_id)
    posts=[]
    #results = @neo.execute_script("g.idx('users')[[id:'#{user_id}']].out('followings').out('posts').sort{-it.created_at}._()[0..99]")
    results = @neo.execute_query("start u=node:users(id=\"#{user_id}\") match u-[:followings]->followers-[:posts]->newsfeed return newsfeed order by newsfeed.created_at desc limit 100")
    #results.each{|res|
    results['data'].each {|res|
      #posts << res['data']
      posts << res[0]['data']
    }
    return posts
  end
end