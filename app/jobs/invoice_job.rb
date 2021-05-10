class InvoiceJob < ApplicationJob
  def perform(invoice_id, opts = {})
    print "···································································"
    puts "O invoice passado foi: #{invoice_id} !"
    print "···································································"
  end
end