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
    hatena_entry('http://www.hatena.ne.jp/') do |ent, bm|
      count += 1
    end
    assert_equal(10, count)
  end

  def test_specified_enum()
    count = 0
    hatena_entry('http://www.hatena.ne.jp/', 3) do |ent, bm|
      count += 1
    end
    assert_equal(3, count)
  end

  def test_entry()
    bmk = nil
    entry = nil
    hatena_entry('http://www.hatena.ne.jp/', 1) do |ent, bm|
      bmk = bm
      entry = ent
    end
    assert_equal 'http://www.hatena.ne.jp/', entry['url']
    assert_equal 'はてな', entry['title']
    assert_not_nil bmk
    assert Time === bmk.timestamp
    assert String === bmk.user
    assert bmk.respond_to? :comment
    assert bmk.respond_to? :tags
  end

  def test_latest_entry()
    ent = nil
    count = 0
    hatena_latest_entry('http://github.com/') do |title, href|
      assert(/\A.+-\sGitHub\Z/ =~ title)
      assert(%r|\Ahttps?://github.com/| =~ href, "#{href} not mutch!")
      count += 1
    end
    assert_equal 20, count
  end
end

