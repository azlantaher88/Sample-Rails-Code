require_relative '../test_helper'

class UserTest < ActiveSupport::TestCase
  def test_create_defaults
    user = User.create(
      email: 'test@example.com',
      password: 'testerizer9',
      signup_request: 'Example signup request with sufficient verbosity'
    )

    assert_created user
  end

  def test_create_requirements
    user = User.create

    assert_not_created user
    assert_errors_on user, :email, :password, :signup_request
  end

  def test_create_dummy
    user = User.create_dummy

    assert_created user
  end
end
