class Saasu::Payment < Saasu::Base
  allowed_methods :show, :index, :destroy, :update, :create
  filter_by %W(LastModifiedFromDate LastModifiedToDate ForInvoiceId ClearedFromDate ClearedToDate TransactionType PaymentFromDate PaymentToDate PaymentAccountId PageSize Page)
end
