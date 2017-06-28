class Saasu::Contact < Saasu::Base
  allowed_methods :show, :index, :destroy, :update, :create
  filter_by %W(LastModifiedFromDate LastModifiedToDate GivenName FamilyName IsActive IsCustomer IsSupplier IsContractor IsPartner Tags TagSelection Email ContactId PageSize Page)
end