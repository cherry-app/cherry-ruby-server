class AddOtpCount < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :otp_count, :integer
  end
end
