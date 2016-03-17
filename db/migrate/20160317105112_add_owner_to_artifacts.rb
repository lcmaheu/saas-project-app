class AddOwnerToArtifacts < ActiveRecord::Migration
  def change
    add_column :artifacts, :owner, :integer
  end
end
