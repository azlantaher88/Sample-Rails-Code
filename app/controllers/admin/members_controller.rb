class Admin::MembersController < Admin::BaseController
  before_action :load_user, except: [ :index, :new, :create ]

  selection :all
  selection :admin
  selection :trusted
  selection :registered
  selection :rejected
  selection :banned

  def index
    @users = self.selection_scope.order('created_at DESC').page(params[:page] || 1)
  end

  def show
  end

  def edit
    @user.role ||= User.role_default
  end

  def update
    @user.skip_reconfirmation!
    @user.update_attributes!(user_params)

    redirect_to(admin_member_path(@user))

  rescue ActiveRecord::RecordInvalid
    delegate(:edit)
  end

  def approve
    # FUTURE: Create an approval record
    @user.trusted_by_user = session_user
    @user.rejected = false
    @user.trusted = true
    @user.role = 'trusted'

    @user.save!

    UserMailer.account_request_approved(@user).deliver_now

    redirect_back_to(admin_member_path(@user))
  end

  def confirm
    # FUTURE: Create a confirmation record
    @user.skip_reconfirmation!
    @user.confirmed!
    @user.save!

    redirect_back_to(admin_member_path(@user))
  end

  def ban
    # FUTURE: Create a ban record
    @user.role = nil
    @user.banned_by_user = session_user
    @user.banned!

    redirect_back_to(admin_member_path(@user))
  end

  def reinstate
    # FUTURE: Create a ban record
    @user.trusted_by_user = session_user
    @user.banned!(false)

    redirect_back_to(admin_member_path(@user))
  end

  def reject
    @user.rejected_by_user = session_user
    @user.rejected!

    UserMailer.account_request_rejected(@user).deliver_now

    redirect_back_to(admin_member_path(@user))
  end

protected
  def scope
    User
  end

  def load_user
    @user = User.find(params[:id])
  end

  def user_params
    params.fetch(:user, { }).permit!
  end
end
