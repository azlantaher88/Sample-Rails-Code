require_relative '../test_helper'

class NewsItemTest < ActiveSupport::TestCase
  def test_create_defaults
    user = a User

    news_item = NewsItem.create(
      headline: 'News Headline',
      byline: 'Author Name',
      content: 'News content',
      link: 'http://example.com/',
      user: user
    )

    assert_created news_item
  end

  def test_create_requirements
    news_item = NewsItem.create

    assert_not_created news_item

    assert_errors_on news_item, :headline, :content, :user
  end

  def test_create_dummy
    news_item = NewsItem.create_dummy

    assert_created news_item

    assert news_item.headline?
    assert news_item.content?
  end
end
