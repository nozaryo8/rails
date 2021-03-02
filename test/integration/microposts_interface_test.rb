require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test "micropost interface" do
    log_in_as(@user)
    get root_path
    # 特定のHTMLタグが存在する→ class = "pagination"を持つdiv
    assert_select 'div.pagination'
    # 特定のHTMLタグが存在する→ type="file"を持つinput
    assert_select 'input[type="file"]'
    
    # 無効な送信
    # ブロックで渡されたものを呼び出す前後でMicropost.countに違いがない
    assert_no_difference 'Micropost.count' do
      # microposts_pathにpostのリクエスト　→　micropost: { content: "" }（無効なデータ）
      post microposts_path, params: { micropost: { content: "" } }
    end
    # 特定のHTMLタグが存在する→　id = "error_explanation"を持つdiv
    assert_select 'div#error_explanation'
    assert_select 'a[href=?]', '/?page=2'  # 正しいページネーションリンク
    
    # 有効な送信
    # contentに代入　→　"This micropost really ties the room together"
    content = "This micropost really ties the room together"
    # imageに代入→ fixtureで定義されたファイルをアップロードするメソッド（パス, タイプ）
    image = fixture_file_upload('test/fixtures/kitten.jpg', 'image/jpeg')
    # ブロックで渡されたものを呼び出す前後でMicropost.countが+1
    assert_difference 'Micropost.count', 1 do
      # microposts_pathにpostのリクエスト　→　micropost: { content: content, picture: picture }（有効なデータ）
      post microposts_path, params: { micropost:
                                      { content: content, image: image } }
    end
    
    #assert FILL_IN.image.attached?　わからん
    #　指定されたリダイレクト先に移動
    follow_redirect!
    # 表示されたページのHTML本文すべての中にcontentが含まれている
    assert_match content, response.body
    
    # 投稿を削除する
    # 特定のHTMLタグが存在する→　text: '削除'を持つa
    assert_select 'a', text: 'delete'
    # first_micropostに代入　@user.micropostsの1ページ目の1番目のマイクロポスト
    first_micropost = @user.microposts.paginate(page: 1).first
    # ブロックで渡されたものを呼び出す前後でMicropost.countが-1
    assert_difference 'Micropost.count', -1 do
      # micropost_path(first_micropost)にdeleteのリクエスト
      delete micropost_path(first_micropost)
    end
    # 違うユーザーのプロフィールにアクセス（削除リンクがないことを確認）
    # user_path(users(:archer))にgetのリクエスト
    get user_path(users(:archer))
    # 特定のHTMLタグが存在する→　text: '削除'を持つaが0個
    assert_select 'a', text: 'delete', count: 0
  end
  
  test "micropost sidebar count" do
    log_in_as(@user)
    get root_path
     # 表示されたページのHTML本文すべての中に　#{@user.microposts.count} microposts　が含まれている
    assert_match "#{@user.microposts.count} microposts", response.body
    
    # まだマイクロポストを投稿していないユーザー
    other_user = users(:malory)
    #other_userでログイン
    log_in_as(other_user)
    get root_path
    # 表示されたページのHTML本文すべての中に　0 microposts　が含まれている
    assert_match "0 microposts", response.body
    # other_userに紐づいたmicropostを作成（content属性に値"A micropost"をセット）
    other_user.microposts.create!(content: "A micropost")
    get root_path
    # 表示されたページのHTML本文すべての中に　1 micropost　が含まれている （micropostsではなく単数形にする）
    # HTMLではpluralizeメソッドを使って “1 micropost” や “2 microposts” と表示するように調整している
    assert_match "1 micropost", response.body
  end
end
