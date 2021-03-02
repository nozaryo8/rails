require 'test_helper'

class MicropostsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @micropost = microposts(:orange)
  end

  test "should redirect create when not logged in" do
    # ブロックで渡されたものを呼び出す前後でMicropost.countに違いがない
    assert_no_difference 'Micropost.count' do
      # microposts_pathに　paramsハッシュのデータを持たせてpostのリクエスト
      post microposts_path, params: { micropost: { content: "Lorem ipsum" } }
    end
    assert_redirected_to login_url
  end

  test "should redirect destroy when not logged in" do
    # ブロックで渡されたものを呼び出す前後でMicropost.countに違いがない
    assert_no_difference 'Micropost.count' do
      # micropost_path(@micropost)にdeleteのリクエスト
      delete micropost_path(@micropost)
    end
    assert_redirected_to login_url
  end
  
  test "should redirect destroy for wrong micropost" do
    log_in_as(users(:michael))
    micropost = microposts(:ants)
    assert_no_difference 'Micropost.count' do
      delete micropost_path(micropost)
    end
    assert_redirected_to root_url
  end
  
end
