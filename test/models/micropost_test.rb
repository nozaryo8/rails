require 'test_helper'

class MicropostTest < ActiveSupport::TestCase
  def setup
    @user = users(:michael)
    # このコードは慣習的に正しくない
    #micropost = Micropost.new(content: "Lorem ipsum", user_id: @user.id)
    # なので正しいコードに修正↓
    # @userに紐づいたMicropostオブジェクトを返す（content属性に"Lorem ipsum"の値を持つ）
    @micropost = @user.microposts.build(content: "Lorem ipsum")
  end

  test "should be valid" do
    assert @micropost.valid?
  end

  test "user id should be present" do
    @micropost.user_id = nil
    assert_not @micropost.valid?
  end
  
  test "content should be present" do
    @micropost.content = "   "
    # trueである→　@micropostは有効か
    assert_not @micropost.valid?
  end

  test "content should be at most 140 characters" do
    # @micropost.contentにa×141（141文字）を追加
    @micropost.content = "a" * 141
    # falseである→　@micropostは有効か
    assert_not @micropost.valid?
    
    # 140文字の時有効
    @micropost.content = "a" * 140
    assert @micropost.valid?
    # 139文字の時有効
    @micropost.content = "a" * 139
  end
  
  test "order should be most recent first" do
    # 第一引数と第二引数が等しい　microposts（fixture）の:most_recent　と　Micropostオブジェクトの1つ目
    assert_equal microposts(:most_recent), Micropost.first
  end
end
