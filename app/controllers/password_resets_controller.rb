class PasswordResetsController < ApplicationController
  # フィルタの内容は下部private以下
  before_action :get_user,   only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]    # （1）への対応
  
  def new
  end
  
  def create
    # # @userに代入→（フォームに入力された）email(を小文字にしたやつ）を持ったuserをDBから見つけてる
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      # @userのパスワード再設定の属性を設定する（create_reset_digestはapp/models/user.rbにある）
      @user.create_reset_digest
      # @userにパスワード再設定メールを送る（send_password_reset_emailはapp/models/user.rbにある）
      @user.send_password_reset_email
      flash[:info] = "Email sent with password reset instructions"
      redirect_to root_url
    else
      flash.now[:danger] = "Email address not found"
      render 'new'
    end
  end
  
  def edit
  end
  
  def update
    if params[:user][:password].empty?                  # （3）への対応
      #オブジェクト.errors.add(対象のカラム, ‘エラーの内容’)エラーの内容にblankオプションを指定することで適切なメッセージを表示してくれる
      @user.errors.add(:password, :blank)
      render 'edit'
      
    # @userの:reset_digestの値をnilに更新して保存
    elsif @user.update(user_params)                     # （4）への対応
      log_in @user
      @user.update_attribute(:reset_digest, nil)
      flash[:success] = "Password has been reset."
      redirect_to @user
    else
      # editのビューを描画
      render 'edit'                                     # （2）への対応
    end
  end
  
  
  private
    #:user必須
    #パスワード、パスワードの確認の属性をそれぞれ許可
    #それ以外は許可しない
    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end
    
    # beforeフィルタ
    
    def get_user
      @user = User.find_by(email: params[:email])
    end

    # 正しいユーザーかどうか確認する
    def valid_user
      unless (@user && @user.activated? &&
              @user.authenticated?(:reset, params[:id]))
        redirect_to root_url
      end
    end
    
    # トークンが期限切れかどうか確認する
    def check_expiration
      # password_reset_expired→期限切れかどうかを確認するインスタンスメソッド user.rbに定義
      if @user.password_reset_expired?
        flash[:danger] = "Password reset has expired."
        redirect_to new_password_reset_url
      end
    end
end
