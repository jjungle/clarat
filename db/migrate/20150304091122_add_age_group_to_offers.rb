class AddAgeGroupToOffers < ActiveRecord::Migration
  def change
    add_column :offers, :age_group, :string
  end
end
