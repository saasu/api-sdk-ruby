module Saasu
  class Search
    VALID_SCOPES = %W(All Transactions Contacts InventoryItems)
    attr_accessor :scope, :keywords

    def initialize(keywords, scope = 'All')
      @scope = scope
      @keywords = keywords

      validate_scope!
    end

    def perform
      perform_search!
      { contacts: search_results['TotalContactsFound'], invoices: search_results['TotalTransactionsFound'], items: search_results['TotalInventoryItemsFound'] }
    end

    def contacts
      search_results["Contacts"].map do |contact|
        Saasu::Contact.new(contact)
      end
    end

    def invoices
      search_results["Transactions"].map do |contact|
        Saasu::Invoice.new(contact)
      end
    end

    def items
      search_results["InventoryItems"].map do |contact|
        Saasu::Item.new(contact)
      end
    end

    private
    def perform_search!
      @search_results = Saasu::Client.request(:get, 'search', { Scope: @scope, Keywords: @keywords, IncludeSearchTermHighlights: false })
    end

    def search_results
      @search_results ||= perform_search!
    end

    def validate_scope!
      unless @scope.in? VALID_SCOPES
        raise "Invalid scope argument. Valid values are: #{VALID_SCOPES.join(', ')}"
      end
    end
  end
end
