require 'minitest/autorun'

class Array
  def where(search_term)
    search_term = search_term.to_a
    results_array = []
    results = []
    self.each do |look_for|
      if look_for.key?(search_term[0][0])
        key = search_term[0][0]
        value = look_for[key.to_sym]

        if value == search_term[0][1]
          results_array << look_for
        elsif !search_term[0][1].is_a?(String) && value =~ search_term[0][1]
          results_array << look_for
        else
        end
        
        if search_term.length > 1
          results_array.each do |look_for2|
            if look_for2.key?(search_term[1][0])
              key2 = search_term[1][0]
              value2 = look_for2[key2.to_sym]
              
              if value2 != search_term[1][1]
              elsif !search_term[1][1].is_a?(String) && value2 =~ search_term[1][1]
                results << look_for2
              else
              end
            end
          end
          results_array = results
        end
      end
    end
    return results_array
  end
end


class WhereTest < Minitest::Test
  def setup
    @boris   = {:name => 'Boris The Blade', :quote => "Heavy is good. Heavy is reliable. If it doesn't work you can always hit them.", :title => 'Snatch', :rank => 4}
    @charles = {:name => 'Charles De Mar', :quote => 'Go that way, really fast. If something gets in your way, turn.', :title => 'Better Off Dead', :rank => 3}
    @wolf    = {:name => 'The Wolf', :quote => 'I think fast, I talk fast and I need you guys to act fast if you wanna get out of this', :title => 'Pulp Fiction', :rank => 4}
    @glen    = {:name => 'Glengarry Glen Ross', :quote => "Put. That coffee. Down. Coffee is for closers only.",  :title => "Blake", :rank => 5}

    @fixtures = [@boris, @charles, @wolf, @glen]
  end

  def test_where_with_exact_match
    assert_equal [@wolf], @fixtures.where(:name => 'The Wolf')
  end

  def test_where_with_partial_match
    assert_equal [@charles, @glen], @fixtures.where(:title => /^B.*/)
  end

  def test_where_with_mutliple_exact_results
    assert_equal [@boris, @wolf], @fixtures.where(:rank => 4)
  end

  def test_with_with_multiple_criteria
    assert_equal [@wolf], @fixtures.where(:rank => 4, :quote => /get/)
  end

  def test_with_chain_calls
    assert_equal [@charles], @fixtures.where(:quote => /if/i).where(:rank => 3)
  end
end