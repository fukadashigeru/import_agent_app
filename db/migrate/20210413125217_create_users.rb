class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :name, null: false, comment: 'ユーザ名'
      t.string :email, null: false, index: { unique: true }, comment: 'メールアドレス'
      t.string :password_digest, comment: 'パスワードのハッシュ値'
      t.string :remember_digest, comment: '記憶トークンのハッシュ値'
      t.string :activation_digest, comment: 'アクティベートトークンのハッシュ値'
      t.boolean :activated, default: false, null: false, comment: 'メールアドレス確認済みかどうか'
      t.datetime :activated_at, comment: 'メールアドレス確認完了時刻'
      t.datetime :agreed_at, comment: '招待承認時刻'
      t.string :reset_digest, comment: 'パスワードリセットトークンのハッシュ値'
      t.datetime :reset_sent_at, comment: 'パスワードリセットメールの送信日時'

      t.timestamps
    end
  end
end
