tweet_list = [
  ['Aaron1', 'Message1'],
  ['Aaron2', 'Message2'],
  ['Aaron3', 'Message3'],
  ['Aaron4', 'Message4']
]

# tweet_list = [
#   [ "Germany", 81831000 ],
#   [ "France", 65447374 ],
#   [ "Belgium", 10839905 ],
#   [ "Netherlands", 16680000 ]
# ]

tweet_list.each do |username, content|
  Tweet.create(username: username, content: content)
end
