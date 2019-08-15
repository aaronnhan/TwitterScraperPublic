class ApplicationController < ActionController::Base
  def home_screen
    $twitter_client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
      config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
      config.access_token_secret = ENV['TWITTER_ACCESS_SECRET']
    end
  end

  def search
    options = { count: 100, include_rts: false }
    @username = params[:username]
    timeline = $twitter_client.user_timeline(@username, options)
    time_hash = {}
    @popularity_time_hash = {}

    timeline.each do |t|
      popularity = t.favorite_count
      time = t.created_at.getlocal
      time_key = time.hour * 60 + time.min
      if time_hash.include? time_key
        time_hash[time_key].append(popularity)
      else
        time_hash[time_key] = [popularity]
      end
    end

    time_hash.each do |time, popularities|
      average = popularities.inject(0, :+) / popularities.length
      @popularity_time_hash[time] = average
    end
  end
end
