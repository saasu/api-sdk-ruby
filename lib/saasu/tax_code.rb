class Saasu::TaxCode < Saasu::Base
  allowed_methods :show, :index
  filter_by %W(IsActive Page PageSize)
end
