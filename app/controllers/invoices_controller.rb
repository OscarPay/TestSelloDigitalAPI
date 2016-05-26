class InvoicesController < ApplicationController
  require 'rest-client'

  def index
    path = Rails.root.join("public", "invoices")
    Dir.mkdir(path) unless File.exist?(path)

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

  def new
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

    json_invoice = {invoice: {serie: 'Z', folio: 1, date: Time.zone.now,
                              payment_form: 'Pago en una sola exhibición.',
                              num_account: 4444, payment_conditions: 'muchas',
                              note: 'asdasd', discount_amount: 50,
                              branch_attributes: {name: 'La baticueva', phone: 9343434,
                                                  address_attributes: address_invoice}
                              #receptor_attributes: {rfc: 'TDA000320EV3', social_reason: 'Pruebas',
                              #                     address_attributes: address_invoice},
                              #issuer_attributes: {social_reason: 'Pruebas', rfc: 'ROCV890731AE7',
                              #                   fiscal_regime: 'Pruebas', address_attributes: address_invoice},
                              #concepts_attributes: { quantity: 5, unit: 4, description: 'Producto de Prueba',
                              #                      amount: 200, price: 50, iva_type_id: 2}
    }}

    @response = RestClient.post('http://0.0.0.0:3000/api/invoices', json_invoice)
  end

end
