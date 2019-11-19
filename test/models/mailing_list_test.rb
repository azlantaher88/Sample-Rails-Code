require 'test_helper'

class MailingListTest < ActiveSupport::TestCase
  def test_create_defaults
    mailing_list = MailingList.create(
      name: 'test',
      description: 'Test List'
    )

    assert_created mailing_list

    assert !mailing_list.special?
    assert !mailing_list.internal?
  end
end
