class ApplicationMailer < ActionMailer::Base
  #送信元のアドレス名、アプリケーション全体で共有
  default from: "noreply@example.com" #リスト 11.11: fromアドレスのデフォルト値を更新したアプリケーションメイラー
  layout 'mailer'
end
