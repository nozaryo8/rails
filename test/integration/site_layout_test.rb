require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest

  test "layout links" do
    get root_path
    assert_template 'static_pages/home'
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
    assert_select "a[href=?]", login_path
    get contact_path
    assert_select "title", full_title("Contact")
    get signup_path
    assert_select "title", full_title("Sign up")
  end
  
  def setup
    @user = users(:michael)
    
  end
  
  test "layout links when logged in user" do
    log_in_as(@user) #ログインしてからテスト
    get root_path #root_pathをgetリクエストした上で以下のテストをする
    assert_select "a[href=?]", root_path, count:2 #ビューにaタグのrootパスが２つあるかテスト
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
    assert_select "a[href=?]", edit_user_path(@user)
    assert_select "a[href=?]", users_path
    assert_select "a[href=?]", user_path(@user) #ヘッダーのProfileのところをテスト
    assert_select "a[href=?]", logout_path
    # 特定のHTMLタグが存在する→ strong id="following"
    assert_select 'strong#following'
    # 描写されたページに@user.following.countを文字列にしたものが含まれる
    assert_match @user.following.count.to_s, response.body
    # 特定のHTMLタグが存在する→ strong id="followers"
    assert_select 'strong#followers'
    # 描写されたページに@user.followers.countを文字列にしたものが含まれる
    assert_match @user.followers.count.to_s, response.body
  end
end
