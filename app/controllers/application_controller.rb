class ApplicationController < ActionController::API
  before_action :authorized

  def encode_token(payload) #{ user_id: 2 }
    JWT.encode(payload, 'my_s3cr3t') #issue a token, store payload in token
  end

  def auth_header
    request.headers['Authorization'] # Bearer <toksen>
  end

  def decoded_token
    if auth_header()
      token = auth_header.split(' ')[1] #[Bearer, <token>]
      begin
        JWT.decode(token, 'my_s3cr3t', true, algorithm: 'HS256')
      rescue JWT::DecodeError
        nil
      end
    end
  end

  def current_user
    byebug
    if decoded_token()
      user_id = decoded_token[0]['user_id']
      @user = User.find_by(id: user_id)
    else
      nil
    end
  end

  def logged_in?
    !!current_user
  end

  def authorized
    
    render json: { message: 'Please log in' }, status: :unauthorized unless logged_in?
  end
end
