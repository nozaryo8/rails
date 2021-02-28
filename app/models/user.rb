class User < ApplicationRecord
  #仮想の属性:remember_token、:activation_token、:reset_tokenをUserクラスに定義
  attr_accessor :remember_token,:activation_token, :reset_token
  #before_save { self.email = email.downcase } 下のdowncasa_emailメソッドに置き換える
  before_save :downcase_email
  before_create :create_activation_digest
  validates :name,  presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  # 渡された文字列のハッシュ値を返す
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # ランダムなトークンを返す
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # 永続セッションのためにユーザーをデータベースに記憶する
  def remember
    self.remember_token = User.new_token
    #selfを省略
    update_attribute(:remember_digest, User.digest(remember_token))
  end
  
   # アカウントを有効にする
  def activate
    #自分のクラスなのでselfは省略できる。両方できることを比較
    #self.update_attribute(:activated,    true)
    #self.update_attribute(:activated_at, Time.zone.now)
    
    #指定のカラムを指定の値に、DBに直接上書き保存(上のコードを一つにまとめる)
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  # 有効化用のメールを送信する
  def send_activation_email
    #Userメイラー内の呼び出しでは、@userがselfに変更されている点にもご注目ください。
    UserMailer.account_activation(self).deliver_now
  end
  
   # パスワード再設定の属性を設定する リスト 12.6
  def create_reset_digest
    # （呼び出し先で考えると）@userのreset_tokenに代入→User.new_token
    self.reset_token = User.new_token
    # :reset_digestの値をUser.digest(reset_token)で上書き保存
    update_columns(reset_digest:  User.digest(reset_token), reset_sent_at: Time.zone.now)
    
  end
  
   # パスワード再設定のメールを送信する　リスト 12.6
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end
  # 渡されたトークンがダイジェストと一致したらtrueを返す
  # def authenticated?(remember_token)
  #   return false if remember_digest.nil?
  #   BCrypt::Password.new(remember_digest).is_password?(remember_token)
  # end
  
  # トークンがダイジェストと一致したらtrueを返す リスト 11.26: 抽象化されたauthenticated?メソッド 
  def authenticated?(attribute, token)
    #sendメソッド: 文字列やシンボルをメソッドで呼び出せる
    #→変数展開した文字列をメソッドとして呼びだすこともできる
    digest = self.send("#{attribute}_digest") #モデル内に..digestがあるのでselfは省略できる
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # ユーザーのログイン情報を破棄する
  def forget
    update_attribute(:remember_digest, nil)
  end
  
  # パスワード再設定の期限が切れている場合はtrueを返す
  def password_reset_expired?
    # reset_sent_atの値（再設定メールの送信時刻）　右辺より早い時刻　2時間前
    reset_sent_at < 2.hours.ago
  end
  
  private
    
    def downcase_email
      # self.email = email.downcase ↓同じ意味
      email.downcase!
    end
    
    def create_activation_digest
      self.activation_token = User.new_token
      self.activation_digest = User.digest(activation_token)
    end #before_createでまだオブジェクトを生成する前なのでselfで値を直接代入する
    
    
    # 永続セッションのためにユーザーをデータベースに記憶する
    # def remember 
    #   #self.remember_token = User.new_token
    #   #update_attribute(:remember_digest, User.digest(remember_token))
    # end ユーザーが既に作成されている為,update_attributeで更新する
end