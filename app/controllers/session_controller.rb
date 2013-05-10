class SessionController < ApplicationController
  def signin
    if signed_in?
      redirect_to root_path and return
    else
      if request.post? && !params[:session].nil? && !params[:session][:username].nil? && !params[:session][:password].nil?
        email_input = params[:session][:username]
        #password_input = create_password_digest(params[:session][:password])
        password_input = params[:session][:password]
        user = User.where(:username => email_input, :password => password_input).first
        if user
          sign_in user
          redirect_to request.referer and return
        else
          @class = "alert alert-error"
          flash[:login_error] = ("Username or Password is invalid. Please check and try again.")
          render 'signin' and return
        end
      end
      render 'signin'
    end
  end

  def signout
    sign_out
    redirect_to root_path
  end

  def signup
    @user = User.new
    if request.post? && !params['user'].nil?
      @user.attributes = params['user']
      if @user.valid? && @user.save
        redirect_to root_path and return
      else
        flash[:signup_error] = ("Please check your input")
      end
    end
    render 'signup'
  end
end
