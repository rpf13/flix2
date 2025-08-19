module ApplicationHelper
  def current_user
    # if there is no session, it would return nil and error, therefore the conditional
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
end
