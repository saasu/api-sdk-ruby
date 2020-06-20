class Saasu::Invoice < Saasu::Base
  allowed_methods :show, :index, :destroy, :update, :create
  filter_by %W(InvoiceNumber PurchaseOrderNumber LastModifiedFromDate LastModifiedToDate TransactionType Tags TagSelection InvoiceFromDate InvoiceToDate InvoiceStatus PaymentStatus BillingContactId PageSize Page)

  def email(email_address = nil)
    if email_address.present?
      url = ['Invoice', id, 'email'].join('/')
      params = { EmailTo: email_address }
    else
      url = ['Invoice', id, 'email-contact'].join('/')
      params = {}
    end

    Saasu::Client.request(:post, url, params)
  end
end
