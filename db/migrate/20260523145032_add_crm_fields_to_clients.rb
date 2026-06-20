class AddCrmFieldsToClients < ActiveRecord::Migration[8.1]
  def change
    add_column :clients, :private_notes, :text
    add_column :clients, :tag, :integer
  end
end
