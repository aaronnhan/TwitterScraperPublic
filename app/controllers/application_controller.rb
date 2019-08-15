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
    options = { count: 100, include_rts: true }
    @username = params[:username]
    timeline = $twitter_client.user_timeline(@username, options)
    time_array = []
    @popularity_time_hash = {}

    24.times do
      time_array << []
    end

    timeline.each do |t|
      popularity = t.favorite_count
      hour = t.created_at.hour
      time_array[hour].append(popularity)
    end

    for i in 0..23
      average = time_array[i].inject(0, :+) / time_array.length
      @popularity_time_hash[i] = average
    end
  end
end
