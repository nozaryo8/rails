require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest
  def setup
    # deliveries変数に配列として格納されたメールをクリア
    ActionMailer::Base.deliveries.clear
    @user = users(:michael)
  end

  test "password resets" do
    get new_password_reset_path
    # password_resets/newを描画
    assert_template 'password_resets/new'
    assert_select 'input[name=?]', 'password_reset[email]'
    
    # メールアドレスが無効
    # password_resets_path（password_resets#create）にpostのリクエスト　無効なemailの値
    post password_resets_path, params: { password_reset: { email: "" } }
    assert_not flash.empty?
    assert_template 'password_resets/new'
    
    # メールアドレスが有効
    post password_resets_path,
         params: { password_reset: { email: @user.email } }
    # 引数の値が同じものではない→　@user.reset_digestと@user.reload.reset_digest
    assert_not_equal @user.reset_digest, @user.reload.reset_digest
    # 引数の値が等しい　１とActionMailer::Base.deliveriesに格納された配列の数
    assert_equal 1, ActionMailer::Base.deliveries.size
    # falseである→　flashがemptyである
    assert_not flash.empty?
    assert_redirected_to root_url
    
    # パスワード再設定フォームのテスト
    # userに@userを代入（通常統合テストからはアクセスできないattr_accessorで定義した属性の値にもアクセスできるようになる）
    user = assigns(:user)
    # メールアドレスが無効
    # edit_password_reset（password_resets#edit）にgetのリクエスト（有効なuser.reset_tokenと無効なemailを） 
    get edit_password_reset_path(user.reset_token, email: "")
    assert_redirected_to root_url
    
    # 無効なユーザー
    # userの以下のキー（:activated）の値をtoggle!メソッドで反転（無効なユーザーに）
    user.toggle!(:activated)
    # edit_password_reset（password_resets#edit）にgetのリクエスト　（無効なトークンと無効なemailを）
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_redirected_to root_url
    # userの以下のキー（:activated）の値をtoggle!メソッドで反転（無効なユーザーにしたのをさらに反転して有効なユーザーに）
    user.toggle!(:activated)
    
    # メールアドレスが有効で、トークンが無効
    # edit_password_reset（password_resets#edit）にgetのリクエスト　（無効なトークンと有効なemailを）
    get edit_password_reset_path('wrong token', email: user.email)
    assert_redirected_to root_url
    # メールアドレスもトークンも有効
    # edit_password_reset（password_resets#edit）にgetのリクエスト（有効なトークンとemailを）
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template 'password_resets/edit'
    # 特定のHTMLタグが存在する→　
    # input name="email" type="hidden" value="michael@example.com"(第2引数のuser.emailが入る)
    assert_select "input[name=email][type=hidden][value=?]", user.email
    
    # 無効なパスワードとパスワード確認
    # 引数にuser.reset_tokenを持ったpassword_reset_pathにpatchのリクエスト
    # email: user.emailと無効なパスワードとパスワード確認（それぞれの値が合わない）
    patch password_reset_path(user.reset_token),
          params: { email: user.email,
                    user: { password:              "foobaz",
                            password_confirmation: "barquux" } }
    # 特定のHTMLタグが存在する→　div id="error_explanation"
    assert_select 'div#error_explanation'
    
    # パスワードが空
    # 引数にuser.reset_tokenを持ったpassword_reset_pathにpatchのリクエスト
    # email: user.emailと空のパスワード
    patch password_reset_path(user.reset_token),
          params: { email: user.email,
                    user: { password:              "",
                            password_confirmation: "" } }
    # 特定のHTMLタグが存在する→　div id="error_explanation"
    assert_select 'div#error_explanation'
    
    
    # 有効なパスワードとパスワード確認
    # 引数にuser.reset_tokenを持ったpassword_reset_pathにpatchのリクエスト
    # email: user.emailと有効なパスワードとパスワード確認
    patch password_reset_path(user.reset_token),
          params: { email: user.email,
                    user: { password:              "foobaz",
                            password_confirmation: "foobaz" } }
    # trueである　テストユーザーがログイン（test_helper.rbからメソッドの呼び出し）
    assert is_logged_in?
    # nilであればture → 再取得したuserのreset_digest
    assert_nil user.reload.reset_digest
    assert_not flash.empty?
    assert_redirected_to user
  end
  
  test "expired token" do
    # new_password_reset_path(password_resets#new)へgetのリクエスト
    get new_password_reset_path
    # password_resets_pathにpostのリクエスト　有効なemailの値
    post password_resets_path,
         params: { password_reset: { email: @user.email } }
    # @userに@userを代入（通常統合テストからはアクセスできないattr_accessorで定義した属性の値にもアクセスできるようになる）
    @user = assigns(:user)
    # @userのreset_sent_atを3時間前に上書き
    @user.update_attribute(:reset_sent_at, 3.hours.ago)
    # @user.reset_tokenを引数に持ったpassword_reset_pathにpacthのリクエスト
    # @user.emailと有効なパスワードとパスワード確認
    patch password_reset_path(@user.reset_token),
          params: { email: @user.email,
                    user: { password:              "foobar",
                            password_confirmation: "foobar" } }
    # レスポンスは以下になるはず　→　リダイレクト
    assert_response :redirect
    #　POSTの送信結果に沿って指定されたリダイレクト先に移動
    follow_redirect!
    # リダイレクトされたページに'有効期限が切れています'が含まれている
    # 日本語化の影響で下記だけど、本文通りの場合は→ assert_match /expired/i, response.body
    assert_match '有効期限が切れています', response.body
  end
end
