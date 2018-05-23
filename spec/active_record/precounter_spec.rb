RSpec.describe ActiveRecord::Precounter do
  describe '#precount' do
    context 'When the target records exist' do
      before do
        3.times do |i|
          tweet = Tweet.create
          i.times do
            favorite = Favorite.create(tweet: tweet)
          end
        end
      end

      after do
        Tweet.delete_all
        Favorite.delete_all
      end

      it 'precounts has_many count properly' do
        expected = Tweet.all.map { |t| t.favorites.count }
        expect(
          ActiveRecord::Precounter.new(Tweet.all).precount(:favorites).map { |t| t.favorites_count }
        ).to eq(expected)
      end
    end

    context "When the target records don't exist" do
      after do
        Tweet.delete_all
        Favorite.delete_all
      end

      it 'returns empty array' do
        expect(
          ActiveRecord::Precounter.new(Tweet.all).precount(:favorites)
        ).to eq([])
      end
    end

    context "When the target records has a scope" do
      after do
        Tweet.delete_all
        Favorite.delete_all
      end

      it 'returns correct records' do
        tweet = Tweet.create
        4.times { |i| Favorite.create(tweet: tweet, active: i.even?) }

        precounter = ActiveRecord::Precounter.new(Tweet.all).precount(:favorites, :active_favorites)

        expect(
          precounter.map { |t| [t.favorites_count, t.active_favorites_count] }
        ).to eq([[4, 2]])
      end
    end
  end
end
