class Saasu::Item < Saasu::Base
  allowed_methods :show, :index
  filter_by %W(ItemType SearchMethod SearchText)
end
