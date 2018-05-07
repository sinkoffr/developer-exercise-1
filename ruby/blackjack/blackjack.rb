class Card
  attr_accessor :suite, :name, :value

  def initialize(suite, name, value)
    @suite, @name, @value = suite, name, value
  end
end

class Deck
  attr_accessor :playable_cards
  SUITES = [:hearts, :diamonds, :spades, :clubs]
  NAME_VALUES = {
    :two   => 2,
    :three => 3,
    :four  => 4,
    :five  => 5,
    :six   => 6,
    :seven => 7,
    :eight => 8,
    :nine  => 9,
    :ten   => 10,
    :jack  => 10,
    :queen => 10,
    :king  => 10,
    :ace   => [11, 1]}

  def initialize
    shuffle
  end

  def deal_card
    random = rand(@playable_cards.size)
    @playable_cards.delete_at(random)
  end

  def shuffle
    @playable_cards = []
    SUITES.each do |suite|
      NAME_VALUES.each do |name, value|
        @playable_cards << Card.new(suite, name, value)
      end
    end
  end
end

class Hand
  attr_accessor :cards, :player_hand, :dealer_hand, :player_current_cards, 
                :dealer_current_cards, :player_value, :dealer_value
  
  def initialize
    @cards = []
    @player_current_cards = []
    @dealer_current_cards  = []
    @player_value = []
    @dealer_value = []
    @game = Deck.new
  end
  
  def player_cards 
    @player_hand = @game.deal_card
    @player_current_cards.push("#{@player_hand.name} of #{@player_hand.suite}")
  end
  
  def dealer_cards
    @dealer_hand = @game.deal_card
    @dealer_current_cards.push("#{@dealer_hand.name} of #{@player_hand.suite}")
  end
  
  def deal_cards
    2.times do 
      player_cards
      if @player_hand.name == :ace
        player_value.push(11)
      else
        @player_value.push(player_hand.value)
      end
      dealer_cards
      if @dealer_hand.name == :ace
        @dealer_value.push(11)
      else
        @dealer_value.push(@dealer_hand.value)
      end
    end
    
    puts "The players cards are #{@player_current_cards[0]} and 
          #{@player_current_cards[1]}"
    puts "The dealers visible card is #{@dealer_current_cards[0]}."
    puts "The player has #{@player_value.sum} points"
    
    while @dealer_value.sum < 17 && @player_value.sum < 21
      puts "The dealer is dealt another card..."
      dealer_cards
      if @dealer_hand.name == :ace
        if (@dealer_value.sum + 11) > 21
          @dealer_value.push(1)
        end
        @dealer_value.push(11)
      else
        @dealer_value.push(@dealer_hand.value)
      end
    end
    
    puts "The dealer has #{@dealer_value.sum} points"
    
    if @player_value.sum == 21 && @dealer_value.sum != 21
      puts "BLACKJACK!!! Player WINS"
    elsif @dealer_value.sum == 21
      puts "BLACKJACK! Dealer Wins!!!"
    elsif @player_value.sum > 21
      puts "BUST Player loses!"
    elsif @dealer_value.sum > 21
      puts "dealer busts PLAYER WINS!"
    elsif @dealer_value.sum > @player_value.sum && @dealer_value.sum <= 21
      puts "Dealer WINS!!!"
    else
      puts "PLAYER WINS"
    end
    
    puts "The dealers entire hand is #{@dealer_current_cards}"
  end
end



hand = Hand.new
hand.deal_cards


require 'test/unit'

class CardTest < Test::Unit::TestCase
  def setup
    @card = Card.new(:hearts, :ten, 10)
  end
  
  def test_card_suite_is_correct
    assert_equal @card.suite, :hearts
  end

  def test_card_name_is_correct
    assert_equal @card.name, :ten
  end
  
  def test_card_value_is_correct
    assert_equal @card.value, 10
  end
end

class DeckTest < Test::Unit::TestCase
  def setup
    @deck = Deck.new
  end
  
  def test_new_deck_has_52_playable_cards
    assert_equal @deck.playable_cards.size, 52
  end
  
  def test_dealt_card_should_not_be_included_in_playable_cards
    card = @deck.deal_card
    assert(!@deck.playable_cards.include?(card))
  end

  def test_shuffled_deck_has_52_playable_cards
    @deck.shuffle
    assert_equal @deck.playable_cards.size, 52
  end
end

class HandTest < Test::Unit::TestCase
  def setup
    @hand = Hand.new
    @player_current_cards = []
    @dealer_current_cards = []
    @dealer_value = []
    @card1 = Card.new(:hearts, :ten, 10)
    @card2 = Card.new(:hearts, :ace, 11)
  end
  
  def test_player_is_dealt_a_card
    @hand.deal_cards
    assert_equal @hand.dealer_cards, @hand.dealer_current_cards
  end
  
  def test_dealer_is_dealt_a_card
    @hand.deal_cards
    assert_equal @hand.player_cards, @hand.player_current_cards
  end
  
  def test_dealer_gets_additional_cards_when_value_is_less_than_17
    @hand.deal_cards
    assert_block do 
      if @hand.dealer_value.sum > 17 && @hand.dealer_current_cards.length == 2
        return true
      elsif @hand.dealer_current_cards.length >= 3
        return true
      else 
        return false
      end
    end
  end
  
  def test_player_has_exactly_two_cards
    @hand.deal_cards
    assert_equal @hand.player_current_cards.length, 2
  end
  
  def test_the_dealer_has_at_least_two_cards
    @hand.deal_cards
    assert_block do 
      @hand.dealer_current_cards.length >= 2
    end
  end
  
  def test_that_the_value_of_the_players_hand_is_correct
    @hand.deal_cards
    assert_equal @hand.player_value.sum, (@hand.player_value[0] + @hand.player_value[1])
  end
  
  def test_the_value_of_the_dealers_hand_is_correct
    @hand.deal_cards
    assert_block do
      card_total = []
      i = 0
      while i <= @hand.dealer_current_cards.length
        card_total << @hand.dealer_value[i]
        i += i
        if @hand.dealer_value.sum != card_total.sum
          return false
        end
      end
    end
  end
  
  def test_the_player_is_dealt_a_blackjack
    @hand.deal_cards
    assert_block do
      if @hand.dealer_value.sum != 21
        return false
      else
        return true
      end
    end
    
  end
  
  def test_the_dealer_is_dealt_a_blackjack
    @hand.deal_cards
    assert_block do
      if @hand.dealer_value.sum != 21
        return false
      else
        return true
      end
    end
  end
  
  def test_the_player_is_dealt_a_bust
    assert_block do
      if @hand.player_value.sum > 21
        return true
      else
        return false
      end
    end
  end
  
  def test_the_dealer_is_dealt_a_bust
    assert_block do
      if @hand.dealer_value.sum > 21
        return true
      else
        return false
      end
    end
  end
  
  def test_the_hand_with_the_highest_value_under_21_wins
    assert_block do
      if @hand.dealer_value.sum > 21 && @hand.player_value.sum <= 21
        return true
      elsif @hand.player_value.sum > 21 && @hand.dealer_value.sum <= 21
        return true 
      elsif @hand.dealer_value.sum > @hand.player_value.sum
        return true
      elsif @hand.player_value.sum > @hand.dealer_value.sum
        return true
      else 
        return false
      end
    end
  end
  
end