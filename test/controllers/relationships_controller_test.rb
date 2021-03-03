require 'test_helper'

class RelationshipsControllerTest < ActionDispatch::IntegrationTest
  test "create should require logged-in user" do
    # ブロックで渡されたものを呼び出す前後でRelationship.countに違いがない
    assert_no_difference 'Relationship.count' do
      post relationships_path
    end
    assert_redirected_to login_url
  end

  test "destroy should require logged-in user" do
    # ブロックで渡されたものを呼び出す前後でRelationship.countに違いがない
    assert_no_difference 'Relationship.count' do
      # oneのidのrelationship_pathにdeleteのリクエスト
      delete relationship_path(relationships(:one))
    end
    assert_redirected_to login_url
  end
end
