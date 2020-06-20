class Saasu::Account < Saasu::Base
  allowed_methods :show, :index, :destroy, :update, :create
  filter_by %W(IsActive IsBankAccount AccountType IncludeBuiltIn HeaderAccountId AccountLevel PageSize Page)
end
