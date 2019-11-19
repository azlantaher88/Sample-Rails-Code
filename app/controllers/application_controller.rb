class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :apply_user_time_zone

  layout 'public'

  attr_writer :title

protected
  def session_user
    self.current_user
  end
  helper_method :session_user

  def session_user_role
    if (self.current_user)
      self.current_user.effective_role
    else
      'guest'
    end
  end
  helper_method :session_user_role

  def require_session
    return if (session_user)

    flash[:error] = 'You must be logged in to see your profile.'

    redirect_to(new_user_session_path)
  end

  def require_trusted
    case (session_user_role)
    when 'admin', 'worker', 'trusted'
      true
    else
      flash[:notice] = 'You must be a trusted member of the site to do that.'

      redirect_to(new_user_session_path)
    end
  end

  # REFACTOR: Make this title mechanism more generic and configurable.
  def title
    [ @title, 'Bad Date List' ].compact.join(' - ')
  end
  helper_method :title

  def delegate(action)
    send(action)
    render(action)
  end

  def apply_user_time_zone
    Time.zone = 'Eastern Time (US & Canada)'
  end

  def redirect_param
    params[:r]
  end
  helper_method :redirect_param

  def redirect_back_to(url)
    redirect_to(redirect_param || request.referrer || url)
  end

  def session_user_can?(action)
    case (action)
    when :invite
      case (session_user and session_user.role)
      when 'admin'
        true
      end
    end
  end

  def require_admin
    return if (session_user and session_user.admin?)

    flash[:error] = 'Sorry, administrator privileges are required for that function.'

    redirect_to(root_path)
  end

  def show_validation_errors
    @show_validation_errors = true
  end
end
