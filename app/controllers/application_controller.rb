class ApplicationController < ActionController::Base
  #Sessionヘルパーモジュールの読み込み
  include SessionsHelper
  
  private

    # ユーザーのログインを確認する
    def logged_in_user
      unless logged_in?
        # SessionsHelperメソッド　store_locationの呼び出し
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end
end
