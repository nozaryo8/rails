require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest

  def setup
    @admin     = users(:michael)
    @non_admin = users(:archer)
    @non_activated = users(:non_activated)
  end

  test "index as admin including pagination and delete links" do
    log_in_as(@admin)
    get users_path
    # users/indexが描画される
    assert_template 'users/index'
    # users(:non_activated)が存在しないことを確認
    # 特定のHTMLタグが存在する a href パスはuser_path(@non_activated) 表示テキストは@non_activated.name カウントは0
    assert_select 'a[href=?]', user_path(@non_activated), text: @non_activated.name, count: 0
    assert_select 'div.pagination', count: 2
     # first_page_of_usersにUser.paginate(page: 1)（ユーザー一覧のページ目）を代入
    first_page_of_users = User.paginate(page: 1)
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name #ユーザー名のリンクがあるかどうか
      unless user == @admin
        # 特定のHTMLタグが存在する　a href　パスはuser_path(user)　表示テキストは'削除'
        assert_select 'a[href=?]', user_path(user), text: 'delete' #deleteのリンクがあるかどうか,管理者のアカウントは消せないのでunlessでスキップする
      end
    end
    assert_difference 'User.count', -1 do #deleteを行いUser.countの値が１減ったかどうか
      delete user_path(@non_admin)
    end
    
    # user_path(@non_activated)にgetのリクエスト
    get user_path(@non_activated)
    # root_pathにリダイレクトされる
    assert_redirected_to root_path
  end

  test "index as non-admin" do
    log_in_as(@non_admin)
    get users_path
    assert_select 'a', text: 'delete', count: 0
  end
end
