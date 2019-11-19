class UsersController < Devise::RegistrationsController
  before_action :load_invitation, only: [ :new, :create ]
  before_action :show_validation_errors, only: [ :create, :update ]
  after_action :link_invitation, only: [ :create ]

protected
  def sign_up_params
    params.require(:user).permit(
      :name,
      :email,
      :password,
      :password_confirmation,
      :signup_request,
      :referral_code
    )
  end

  def account_update_params
    params.require(:user).permit(
      :name,
      :email,
      :password,
      :password_confirmation,
      :current_password
    )
  end

  def load_invitation
    params[:invitation_token] ||= params[:v]

    return unless (params[:invitation_token])

    @invitation = Invitation.find_by(token: params[:invitation_token])
  end

  def build_resource(hash = nil)
    super

    if (@invitation)
      resource.email = @invitation.email
      resource.confirmed = true
    end
  end

  def link_invitation
    if (@invitation and resource and !resource.new_record?)
      @invitation.registered_user = resource
      @invitation.state = 'registered'
      @invitation.save
    end
  end
end
