class Admin::VehiclesController < Admin::BaseController
  before_action :load_vehicle, except: [ :index, :new, :create ]

  selection :all,
    scope: lambda { |_| Vehicle.deleted(false) }
  selection :deleted,
    scope: lambda { |_| Vehicle.deleted }

  def index
    @vehicles = self.selection_scope.page(params[:page] || 1)
  end

  def show
  end

  def edit
  end

  def update
    @vehicle.update_attributes!(vehicle_params)

    redirect_to(admin_vehicle_path(@vehicle))

  rescue ActiveRecord::RecordNotFound
    delegate(:edit)
  end

  def destroy
    @vehicle.deleted!
    @vehicle.searchable!(false)

    redirect_to(admin_vehicles_path)
  end

protected
  def scope
    Vehicle.deleted(false)
  end

  def load_vehicle
    @vehicle = Vehicle.find(params[:id])
  end

  def vehicle_params
    params.fetch(:vehicle, { }).permit!
  end
end
