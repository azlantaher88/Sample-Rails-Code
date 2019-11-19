ENV['RAILS_ENV'] ||= 'test'

require_relative '../config/environment'
require 'rails/test_help'

class ActiveSupport::TestCase
  ActiveRecord::Migration.check_pending!

  def fixture_expand_path(name)
    File.expand_path(File.join('fixtures', name), File.dirname(__FILE__))
  end

  def fixture_upload(name, type = nil)
    Rack::Test::UploadedFile.new(fixture_expand_path(name), type)
  end

  def file_upload(path, type = nil)
    Rack::Test::UploadedFile.new(path, type)
  end

  def load_json_fixture(name)
    json_path = File.expand_path(
      File.join('fixtures', '%s.json' % name),
      File.dirname(__FILE__)
    )
    
    JSON.parse(File.read(json_path))
  end

  def assert_equal_with_format(format, expected, actual, message = nil, &block)
    case (expected)
    when Array
      assert_equal(
        expected.collect { |v| format % v },
        actual.collect { |v| format % v },
        message,
        &block
      )
    else
      assert_equal(format % expected, format % actual, message, &block)
    end
  end

  # Add more helper methods to be used by all tests here...
  # Example usage:
  #   assert_exception_raised                                 do ... end
  #   assert_exception_raised ActiveRecord::RecordInvalid     do ... end
  #   assert_exception_raised Plugin::Error, 'error_message'  do ... end
  def assert_exception_raised(exception_class = nil, error_message = nil, &block)
    exception_raised = nil
    yield
  rescue => exception_raised
    if exception_class
      assert_equal exception_class, exception_raised.class, exception_raised.to_s
    else
      assert true
    end
    assert_equal error_message, exception_raised.to_s if error_message
  else
    flunk 'Exception was not raised'
  end

  def assert_created(model)
    assert_not_nil model, "Model was nil"
    assert model, "Model was not defined"
    assert_equal [ ], model.errors.full_messages
    assert model.valid?, "Model failed to validate"

    if (model.respond_to?(:new_record?))
      assert !model.new_record?, "Model is still a new record"
    elsif (model.respond_to?(:new?))
      assert !model.new?, "Model is still a new record"
    end
  end

  def assert_not_created(model)
    assert model, "Model was not defined"
    assert model.new_record?, "Model has been saved"
  end

  def convert_to_ids(*list)
    list.flatten.collect do |e|
      e.respond_to?(:id) ? e.id : e
    end
  end

  def assert_equal_ids(expected, actual, message = nil, &block)
    assert_equal(
      convert_to_ids(expected).sort_by(&:to_i),
      convert_to_ids(actual).sort_by(&:to_i),
      message,
      &block
    )
  end

  def assert_layout(layout)
    assert_equal layout, @response.layout
  end

  def assert_mapping(map)
    result_map = map.inject({ }) do |h, (k,v)|
      if (k and k.respond_to?(:freeze))
        k = k.freeze
      end
      h[k] = yield(k)
      h
    end
    differences = result_map.inject([ ]) do |a, (k,v)|
      if (v != map[k])
        a << k
      end
      a
    end
    assert_equal map, result_map, differences.collect { |s| "Input: #{s.inspect}\n  Expected: #{map[s].inspect}\n  Result:   #{result_map[s].inspect}\n" }.join('')
  end

  def assert_errors_on(record, *attrs)
    found_attrs = [ ]
    record.errors.each do |attr, error|
      found_attrs << attr
    end

    assert_equal(
      attrs.flatten.collect(&:to_s).sort,
      found_attrs.uniq.collect(&:to_s).sort
    )
  end

  def assert_error_on(record, attribute, message = nil)
    error = record.errors.detect do |attr, error|
      attr.to_s == attribute.to_s
    end

    assert error

    if (message)
      assert error.include?(message), error.inspect
    end
  end

  def assert_in_array(array, value)
    assert array.include?(value), "Value was not in the array"
  end

  def example(file)
    File.read(example_path(file))
  end

  def example_path(file)
    File.expand_path(File.join('test', 'examples', file), Rails.root)
  end

  def parse_json_response
    JSON.parse(@response.body)
  end

  # Sign in with a particular user.
  #  :role - Role of given user
  def sign_in!(options = nil)
    sign_out(@user) if (@user)

    role = options && options[:role]

    unless (role.is_a?(Role))
      role = Role.where(id: role).first_or_create
    end

    @user = User.create_dummy(role: role)

    sign_in @user
  end
end

class ActionController::TestCase
  include Devise::Test::ControllerHelpers
end
