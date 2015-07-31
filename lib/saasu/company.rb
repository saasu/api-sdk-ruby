class Saasu::Company < Saasu::Base
  allowed_methods :show, :index, :destroy, :update, :create
  filter_by %W(LastModifiedFromDate LastModifiedToDate CompanyName=)
end
