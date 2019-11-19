module ComfyAuthentication
  def authenticate
    return true if (session_user and session_user.admin?)

    flash[:error] = 'Sorry, administrator privileges are required for that function.'

    redirect_to(root_path)

    false
  end
end
