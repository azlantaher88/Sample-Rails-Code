require_relative '../test_helper'

class VehicleTest < ActiveSupport::TestCase
  def test_create_defaults
    vehicle = Vehicle.create(
      license: 'A1A2B2'
    )

    assert_created vehicle
  end

  def test_create_requirements
    vehicle = Vehicle.create

    assert_not_created vehicle

    assert_errors_on vehicle, :license_r
  end

  def test_create_dummy
    vehicle = Vehicle.create_dummy

    assert_created vehicle

    assert vehicle.license?
  end

  def test_redact_license
    vehicle = Vehicle.create(
      license: 'ABCD012'
    )

    assert_created vehicle

    assert_equal 'A**D012', vehicle.license
  end
end
