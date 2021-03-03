# メインのサンプルユーザーを1人作成する
User.create!(name:  "Example User",
    email: "example@railstutorial.org",
    password:              "foobar",
    password_confirmation: "foobar",
    admin: true,
    activated: true,
    activated_at: Time.zone.now)
    

# 追加のユーザーをまとめて生成する
99.times do |n|
name  = Faker::Name.name
email = "example-#{n+1}@railstutorial.org"
password = "password"
User.create!(name:  name,
      email: email,
      password:              password,
      password_confirmation: password,
      activated: true,
      activated_at: Time.zone.now)
end

# ユーザーの一部を対象にマイクロポストを生成する
# マイクロポストのサンプルを追加
# usersに　Userモデルを　created_atの順に並び替えて　上から（6個を）配列として　代入
users = User.order(:created_at).take(6)
50.times do
  # contentに　Faker::Loremで作ったサンプルを代入（Faker::Loremから文章を5個取り出す）
  content = Faker::Lorem.sentence(word_count: 5)
  # usersを順番に取り出してブロック内を実行
  # 取り出した要素をuserに代入　userに紐づいたmicropostを作成（content属性に変数contentの値）
  users.each { |user| user.microposts.create!(content: content) }
end
#「user1のマイクロポスト１・・・user6のマイクロポスト1、user1のマイクロポスト2・・・user6のマイクロポスト2」といった繰り返しになっている

# 以下のリレーションシップを作成する
# usersにすべてのユーザーを代入
users = User.all
# userにUserテーブルの1番目のユーザーを代入
user  = users.first
# followingにusersの3番目～51番目を代入
following = users[2..50]
# followersにusersの4番目～41番目を代入
followers = users[3..40]
# followingを順に取り出してブロック内を実行
# 取り出した要素をfollowedに代入　userがfollowedをフォロー
following.each { |followed| user.follow(followed) }
# followersを順に取り出してブロック内を実行
# 取り出した要素をfollowerに代入　followerがユーザーをフォロー
followers.each { |follower| follower.follow(user) }