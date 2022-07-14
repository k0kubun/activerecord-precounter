# ActiveRecord::Precounter [![Test](https://github.com/k0kubun/activerecord-precounter/actions/workflows/test.yml/badge.svg)](https://github.com/k0kubun/activerecord-precounter/actions/workflows/test.yml)

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
ActiveRecord::Precounter.new(tweets).precount(:favorites)
tweets.each do |tweet|
  p tweet.favorites_count
end
# SELECT `tweets`.* FROM `tweets`
# SELECT COUNT(`favorites`.`tweet_id`), `favorites`.`tweet_id` FROM `favorites` WHERE `favorites`.`tweet_id` IN (1, 2, 3, 4, 5) GROUP BY `favorites`.`tweet_id`
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'activerecord-precounter'
```

## Limitation

Target `has_many` association must have inversed `belongs_to`.
i.e. `ActiveRecord::Precounter.new(tweets).precount(:favorites)` needs both `Tweet.has_many(:favorites)` and `Favorite.belongs_to(:tweet)`.

Unlike [activerecord-precount](https://github.com/k0kubun/activerecord-precount), the cache store is not ActiveRecord association and it does not utilize ActiveRecord preloader.
Thus you can't use `preload` to eager load counts for nested associations. And currently there's no JOIN support.

## License

MIT License
