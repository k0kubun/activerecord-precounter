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
  end
end
