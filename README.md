# ActiveRecord::Precounter

Yet Another N+1 COUNT Query Killer for ActiveRecord, counter\_cache alternative.  
ActiveRecord::Precounter allows you to cache count of associated records by eager loading.

This is another version of [activerecord-precount](https://github.com/k0kubun/activerecord-precount),
which is not elegant but designed to have no monkey-patch to ActiveRecord internal APIs for maintainability.

## Synopsis

### N+1 count query

Sometimes you may see many count queries for one association.
You can use counter\_cache to solve it, but you need to ALTER table and concern about dead lock to use counter\_cache.

```rb
tweets = Tweet.all
tweets.each do |tweet|
  p tweet.favorites.count
end
# SELECT `tweets`.* FROM `tweets`
# SELECT COUNT(*) FROM `favorites` WHERE `favorites`.`tweet_id` = 1
# SELECT COUNT(*) FROM `favorites` WHERE `favorites`.`tweet_id` = 2
# SELECT COUNT(*) FROM `favorites` WHERE `favorites`.`tweet_id` = 3
# SELECT COUNT(*) FROM `favorites` WHERE `favorites`.`tweet_id` = 4
# SELECT COUNT(*) FROM `favorites` WHERE `favorites`.`tweet_id` = 5
```

### Count eager loading

#### precount

With activerecord-precounter gem installed, you can use `ActiveRecord::Precounter#precount` method
to eagerly load counts of associated records.
Like `preload`, it loads counts by multiple queries

```rb
tweets = Tweet.all
ActiveRecord::Precounter.new(tweets, :favorites).precount
tweets.each do |tweet|
  p tweet.favorites_count
end
# SELECT `tweets`.* FROM `tweets`
# SELECT COUNT(`favorites`.`tweet_id`), `favorites`.`tweet_id` FROM `favorites` WHERE `favorites`.`tweet_id` IN (1, 2, 3, 4, 5) GROUP BY `favorites`.`tweet_id`
```

#### eager\_count

Like `eager_load`, `ActiveRecord::Precounter#eager_count` method allows you to load counts by one JOIN query.

```rb
tweets = Tweet.all
ActiveRecord::Precounter.new(tweets, :favorites).eager_count
tweets.eager_count(:favorites).each do |tweet|
  p tweet.favorites_count
end
# SELECT `tweets`.`id` AS t0_r0, `tweets`.`tweet_id` AS t0_r1, `tweets`.`user_id` AS t0_r2, `tweets`.`created_at` AS t0_r3, `tweets`.`updated_at` AS t0_r4, COUNT(`favorites`.`id`) AS t1_r0 FROM `tweets` LEFT OUTER JOIN `favorites` ON `favorites`.`tweet_id` = `tweets`.`id` GROUP BY tweets.id
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'activerecord-precounter'
```

## Limitation

Unlike [activerecord-precount](https://github.com/k0kubun/activerecord-precount), the cache store is not ActiveRecord association and it does not utilize ActiveRecord preloader/join\_dependency.
Thus it can't eager load nested associations at once. But you can do it after eager loading parent associations of children you want to count.

## License

MIT License
