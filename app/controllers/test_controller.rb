class TestController < ApplicationController
  require 'rest-client'

  def index
    path = Rails.root.join("public", "invoices")

    response = RestClient.get 'http://0.0.0.0:3000/api/invoices/13'
    json_response = JSON.parse(response.body)

    @status = json_response["invoice_status"]
    @invoice = json_response["invoice"]

    xml_doc = Nokogiri::XML(json_response["xml"])

    pdf_doc = Base64.decode64(json_response["pdf_file"])

    File.open(File.join(path, "invoice.xml"), 'w') do |f|
      f.write(xml_doc)
    end

    File.open(File.join(path, "invoice.pdf"), 'wb') do |f|
      f.write(pdf_doc)
    end
  end

  def create

    address_invoice = {
        street: 'c 20 #104',
        num_internal: "50",
        num_outside: 'asdfasd',
        colony: 'Merida',
        location: 'asdfaf',
        municipality: 'Merida',
        reference: "la meztiza",
        cp: '04930'
    }

    json_invoice = {invoice: {serie: 'Z', folio: '1', date: Time.zone.now,
                              payment_form: 'Pago en una sola exhibición.',
                              num_account: 4444, payment_conditions: 'muchas',
                              note: 'asdasd', discount_amount: 50,
                              branch_attributes: {name: 'La baticueva', phone: 9343434,
                                                  address_attributes: address_invoice},
                              receptor_attributes: { rfc: 'asdfasdf' }}}
    @response = RestClient.post('http://0.0.0.0:3000/api/invoice', json_invoice)
  end

end
