class Saasu::Invoice < Saasu::Base
  allowed_methods :show, :index, :destroy, :update, :create
  filter_by %W(InvoiceNumber LastModifiedFromDate LastModifiedToDate TransactionType Tags TagSelection InvoiceFromDate InvoiceToDate InvoiceStatus PaymentStatus ContactId)
end
