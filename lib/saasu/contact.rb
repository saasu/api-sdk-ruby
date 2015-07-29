class Saasu::Contact < Saasu::Base
  allowed_methods :show, :index, :destroy, :update, :insert
  filter_by %W(LastModifiedFromDate LastModifiedToDate GivenName FamilyName IsActive IsCustomer IsSupplier IsContractor IsPartner Tags TagSelection Email ContactId)
end