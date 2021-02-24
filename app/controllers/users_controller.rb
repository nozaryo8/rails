class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy

  def index
    # インスタンス変数@usersに以下を代入
    # Userテーブルからactivated:がtrueのデータをすべて取り出してpaginate(page: params[:page])する
    @users = User.where(activated: true).paginate(page: params[:page])
  end

  def show
    # @userにUserテーブルから(params[:id])のデータを取り出して代入
    @user = User.find(params[:id])
    #root_urlにリダイレクト　trueの場合ここで処理が終了する→　@userが有効ではない場合
    #false(@userが有効）な場合はリダイレクトは実行されない
    redirect_to root_url and return unless @user.activated?
    #同じアクション内でrenderメソッドを複数呼び出すと、エラーになるので、and returnを付ける
  end

  def new
    @user = User.new
    
  end

  def create
    @user = User.new(user_params)
    if @user.save
      # Userモデルで定義したメソッド（send_activation_email）を呼び出して有効化メールを送信
      @user.send_activation_email
      flash[:info] = "メールを確認してアカウントを有効化してね"
      redirect_to root_url
    else
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
    
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)
    end

    # beforeアクション

    # ログイン済みユーザーかどうか確認
    def logged_in_user
      unless logged_in?
        store_location # アクセスしようとしたURLを覚えておく 10.30
        
        flash[:danger] = "Please log in."
        redirect_to login_url 
      end
    end

    # 正しいユーザーかどうか確認
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end

    # 管理者かどうか確認
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end