module SessionHelper

    def signed_in?
       !session[:user_id].nil?
    end

    def current_user
      unless session[:user_id].nil?
        begin
          return User.find(session[:user_id])
        rescue
          return nil
        end
      end
      nil
    end

    def sign_in(user)
      session[:user_id] = user._id
    end

    def sign_out
      session.delete(:user_id)
    end

end
