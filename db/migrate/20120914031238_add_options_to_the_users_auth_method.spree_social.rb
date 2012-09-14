class AddOptionsToTheUsersAuthMethod < ActiveRecord::Migration
  def change
    add_column :spree_authentication_methods, :options, :text
  end
end
