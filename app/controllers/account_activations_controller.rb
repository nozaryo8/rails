class AccountActivationsController < ApplicationController
  
  def edit
    # userに代入→Userテーブルから URLから取得したemailの値を持つ userデータを取得する
    user = User.find_by(email: params[:email])
      # userが存在する かつ userがactivatedではない かつ 有効化トークンとparams[:id](activation_token)が持つ有効化ダイジェストが一致した場合
      #paramsはedit_user GET    /users/:id/edit(.:format)　URLの:idから情報を読み出す
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
    # !user.activated? → ユーザーがactivatedではない。すでに有効なユーザーを再度有効化させないために必要。
      # userで定義したactivateメソッドを呼び出してユーザーを有効化
      user.activate
      # userでログイン（Sessionsヘルパーのlog_inメソッドを呼び出し）
      log_in user
      flash[:success] = "Account activated!"
      # userページにリダイレクト
      redirect_to user
    else
      flash[:danger] = "Invalid activation link"
      redirect_to root_url
    end
  end
end
