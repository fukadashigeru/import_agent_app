class CreateUserRegisterers < ActiveRecord::Migration[6.0]
  def change
    create_table :user_registerers do |t|
      t.string :email, null: false, index: true
      t.string :digest, null: false

      t.timestamps
    end
  end
end
