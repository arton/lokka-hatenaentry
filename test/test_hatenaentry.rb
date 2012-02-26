# coding: utf-8
require 'test/unit'
require_relative '../lib/lokka/hatenaentry'

class TestHatenaEntry < Test::Unit::TestCase
  include Lokka::Helpers
  def setup()
    sleep(1) # avoid dos
  end

  def test_defenum()
    count = 0
    hatena_entry('http://www.hatena.ne.jp/') do |e|
      count += 1
    end
    assert_equal(10, count)
  end

  def test_specified_enum()
    count = 0
    hatena_entry('http://www.hatena.ne.jp/', 3) do |e|
      count += 1
    end
    assert_equal(3, count)
  end
end

