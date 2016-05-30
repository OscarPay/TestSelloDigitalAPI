class InvoicesController < ApplicationController
  require 'rest-client'

  def index
    path = Rails.root.join("public", "invoices")
    Dir.mkdir(path) unless File.exist?(path)

    response = RestClient.get host + '/invoices/13'
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

    #Agregar en el servidor el timbrado al crearlo para ver si le agrega el invoice_status_id

    json_invoice = {invoice: {serie: 'Z', folio: 101, date: Time.zone.now,
                              payment_form: 'Pago en una sola exhibición.',
                              num_account: 4444, payment_conditions: 'muchas',
                              note: 'asdasd', discount_amount: 50, issuer_id: 2,
                              invoice_status_id: 1,
                              receptor_id: 1, branch_id: 1, is_test: 0, invoice_type_id: 1,
                              concepts_attributes: {"0": {quantity: 4, unit: "hola mundo", price: 30, description: "hdsda", iva_type_id: 1},
                                                    "1": {quantity: 5, unit: "hola mundo", price: 31, description: "jejej", iva_type_id: 1}
                              }
    }}

    @response = RestClient.post(host + '/invoices', json_invoice)
  end

  def edit
    @response = RestClient.get(host + "/invoices/#{params[:id]}/stamp")
  end

  private

  def host
    'http://api.localhost.com:3000'
  end

end
