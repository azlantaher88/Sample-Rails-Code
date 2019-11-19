class UserConfirmationsController < Devise::ConfirmationsController
  def show
    super

    UserMailer.account_request_confirmation(self.resource).deliver_now
    UserMailer.account_request_notification(self.resource).deliver_now
  end
end
