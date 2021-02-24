require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  def setup
    # deliveries変数に配列として格納されたメールをクリア
    ActionMailer::Base.deliveries.clear
    #ActionMailer::Base.deliveries.clearとはなんぞ
    #/sample_app/config/environments/test.rbでテスト中のメール送信モードをtestに設定している
    #これにより送信されたメールはdeliveriesという変数に配列として追加されていく
    #この追加されている内容をクリアするためclearメソッドを繋いでいる
    #（setupメソッドでdeliveries（変数を初期化しておかないと、並列する他のテストでエラーが発生する）
  end
  
  test "invalid signup information" do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, params: { user: { name:  "",
                                         email: "user@invalid",
                                         password:              "foo",
                                         password_confirmation: "bar" } }
    end
    assert_template 'users/new'
  end

  # valid signup informationテストに機能追加
  test "valid signup information with account activation" do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name:  "Example User",
                                         email: "user@example.com",
                                         password:              "password",
                                         password_confirmation: "password" } }
    end
    # 引数の値が等しい　１とActionMailer::Base.deliveriesに格納された配列の数
    assert_equal 1, ActionMailer::Base.deliveries.size
    # userに@userを代入（通常統合テストからはアクセスできないattr_accessorで定義した属性の値にもアクセスできるようになる）
    user = assigns(:user)
    # userが有効ではない
    assert_not user.activated?
    # 有効化していない状態でログインしてみる
    log_in_as(user)
    # テストユーザーがログインしていない
    assert_not is_logged_in?
    # 有効化トークンが不正な場合
    get edit_account_activation_path("invalid token", email: user.email)
    # テストユーザーがログインしていない
    assert_not is_logged_in?
    # トークンは正しいがメールアドレスが無効な場合
    get edit_account_activation_path(user.activation_token, email: 'wrong')
    # テストユーザーがログインしていない
    assert_not is_logged_in?
    # 有効化トークンが正しい場合
    get edit_account_activation_path(user.activation_token, email: user.email)
    # userの値を再取得すると有効化している
    assert user.reload.activated?
    # 実際にリダイレクト先に移動
    follow_redirect!
    #sers/showが描写される
    assert_template 'users/show'
    #テストユーザーがログインしている
    assert is_logged_in?
  end
end
