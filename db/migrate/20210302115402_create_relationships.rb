class CreateRelationships < ActiveRecord::Migration[6.0]
  def change
    create_table :relationships do |t|
      t.integer :follower_id
      t.integer :followed_id

      t.timestamps
    end
    add_index :relationships, :follower_id
    add_index :relationships, :followed_id
    # follower_idとfollowed_idの組み合わせが必ずユニークであることを保証する
    # 複合キーインデックスとオプションunique
    add_index :relationships, [:follower_id, :followed_id], unique: true
  end
end
