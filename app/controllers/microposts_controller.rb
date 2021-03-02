class MicropostsController < ApplicationController
  # 直前にlogged_in_userメソッド（ApplicationController）を実行　:create, :destroyアクションにのみ適用
  before_action :logged_in_user, only: [:create, :destroy]
  # 直前にcorrect_userメソッドを実行　destroyアクションにのみ適用
  before_action :correct_user,   only: :destroy

  def create
    # @micropostに　ログイン中のユーザーに紐付いた新しいマイクロポストオブジェクトを返す（引数　micropost_params）
    @micropost = current_user.microposts.build(micropost_params)
    @micropost.image.attach(params[:micropost][:image])
    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to root_url
    else
      @feed_items = current_user.feed.paginate(page: params[:page])
      render 'static_pages/home'
    end
  end

  def destroy
    @micropost.destroy
    flash[:success] = "Micropost deleted"
    # リダイレクト　（request.referrerで返される）一つ前のURL(DELETEリクエストが発行されたページ)　もしくはroot_url
    redirect_to request.referrer || root_url
  end
  
  private
    # micropost属性必須　content属性とimage属性のみ変更を許可
    def micropost_params
      params.require(:micropost).permit(:content, :image)
    end
    
    def correct_user
      # @microposutに代入　current_userのmicropostsからparams[:id]を持つmicropostを取得
      @micropost = current_user.microposts.find_by(id: params[:id])
      redirect_to root_url if @micropost.nil?
    end
    
end
