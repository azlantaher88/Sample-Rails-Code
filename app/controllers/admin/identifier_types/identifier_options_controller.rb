class Admin::IdentifierTypes::IdentifierOptionsController < Admin::IdentifierTypes::BaseController
  before_action :build_identifier_option, only: [ :new, :create ]
  before_action :load_identifier_option, except: [ :new, :create ]

  def new
  end

  def create
    @identifier_option.save!

    redirect_to(admin_identifier_type_path(@identifier_type))

  rescue ActiveRecord::RecordInvalid
    delegate_render(:new)
  end

  def edit
  end

  def update
    @identifier_option.update_attributes!(identifier_option_params)

    redirect_to(admin_identifier_type_path(@identifier_type))

  rescue ActiveRecord::RecordInvalid
    delegate_render(:edit)
  end

protected
  def identifier_option_params
    params.fetch(:identifier_option, { }).permit!
  end

  def build_identifier_option
    @identifier_option = @identifier_type.options.build(identifier_option_params)
  end

  def load_identifier_option
    @identifier_option = @identifier_type.options.find(params[:id])
  end
end
