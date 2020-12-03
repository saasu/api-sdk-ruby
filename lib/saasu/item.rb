class Saasu::Item < Saasu::Base
  allowed_methods :show, :index, :destroy, :update, :create
  filter_by %W(LastModifiedFromDate LastModifiedToDate IsActive ItemType SearchMethod PageSize)
end
