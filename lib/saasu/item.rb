class Saasu::Item < Saasu::Base
  allowed_methods :show, :index, :destroy, :update, :create
  filter_by %W(ItemType SearchMethod SearchText)
end
