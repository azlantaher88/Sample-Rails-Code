class Admin::IdentifierTypes::BaseController < Admin::BaseController
  before_action :load_identifier_type

protected
  def scope
    IdentifierType.order(:record_type, :code)
  end

  def load_identifier_type
    @identifier_type = IdentifierType.find(params[:identifier_type_id] || params[:id])
  end
end
