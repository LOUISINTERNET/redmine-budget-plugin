class AddDisabledToDeliverables < ActiveRecord::Migration
  def change
    add_column :deliverables, :disabled, :boolean, :default => false
  end
end
