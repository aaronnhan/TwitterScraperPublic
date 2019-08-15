class TweetController < ApplicationController
  def new
    @tweet = Tweet.new
  end
end
