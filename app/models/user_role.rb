class UserRole < ActiveRecord::Base
  belongs_to :user
  belongs_to :manageable, :polymorphic => true
end
