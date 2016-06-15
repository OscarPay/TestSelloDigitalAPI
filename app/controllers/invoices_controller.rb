class InvoicesController < ApplicationController
  require 'rest-client'

  def index
    path = Rails.root.join("public", "invoices")
    Dir.mkdir(path) unless File.exist?(path)

    response = RestClient.get host + '/invoices/20'
    json_response = JSON.parse(response.body)

    @status = json_response["invoice_status"]
    @invoice = json_response


    if @status === "Timbrada"
      xml_doc = Nokogiri::XML(json_response["xml"])
      pdf_doc = Base64.decode64(json_response["pdf_file"])

      File.open(File.join(path, "invoice.xml"), 'w') do |f|
        f.write(xml_doc)
      end

      File.open(File.join(path, "invoice.pdf"), 'wb') do |f|
        f.write(pdf_doc)
      end
    end

  end

  def new

    #Agregar en el servidor el timbrado al crearlo para ver si le agrega el invoice_status_id
    json_invoice = {invoice: {serie: 'Y', folio: 12, date: Time.zone.now,
                              payment_form: 'Pago en una sola exhibición.',
                              payment_conditions: 'muchas',
                              note: 'asdasd', discount_amount: 50, issuer_rfc: 'AAD990814BP7',
                              payment_method_id: 1, receipt_type_id: 2, money_id: 1,
                              receptor_rfc: 'FEHI840824SUA', branch_name: "OFICINA MICHOACAN", is_test: 0,
                              invoice_type_id: 1, discount_type_id: 1,
                              concepts_attributes: {"0": {quantity: 4, unit: "hola mundo", price: 30,
                                                          description: "hdsda", iva_type_id: 1},
                                                    "1": {quantity: 5, unit: "hola mundo", price: 31,
                                                          description: "jejej", iva_type_id: 1}
                              }
    }}

    @response = RestClient.post(host + '/invoices', json_invoice)
  end

  def new_full

    address_invoice = {
        street: 'c 20 #104',
        num_internal: "50",
        num_outside: 'asdfasd',
        colony: 'Merida',
        location: 'asdfaf',
        municipality: 'Merida',
        reference: "la meztiza",
        state_id: 1,
        cp: '04930'
    }

    #Agregar en el servidor el timbrado al crearlo para ver si le agrega el invoice_status_id
    json_invoice = {invoice: {serie: 'N', folio: 5, date: Time.zone.now,
                              payment_form: 'Pago en una sola exhibición.',
                              payment_conditions: 'muchas',
                              note: 'asdasd', discount_amount: 50, issuer_rfc: 'AAD990814BP7',
                              payment_method_id: 1, receipt_type_id: 1, money_id: 1,
                              is_test: 0, invoice_type_id: 1, discount_type_id: 1,
                              branch_attributes: [name: "Sucursal prueba2", phone: "hola", serie: "K", folio: "1",
                                                  address_attributes: address_invoice],
                              receptor_attributes: [name: "Prueba", social_reason: "Prueba Reason", rfc: "PEAO971212A8A",
                                                    email: "test@hotmail.com", address_attributes: address_invoice],
                              concepts_attributes: {"0": {quantity: 4, unit: "hola mundo2", price: 30,
                                                          description: "hdsda", iva_type_id: 1},
                                                    "1": {quantity: 5, unit: "hola mundo2", price: 31,
                                                          description: "jejej", iva_type_id: 1}
                              }
    }}

    @response = RestClient.post(host + '/invoices/create_full', json_invoice)
  end

  def edit
    @response = RestClient.get(host + "/invoices/#{params[:id]}/stamp")
  end

  def destroy
    @response = RestClient.get(host + "/invoices/#{params[:id]}/cancel")
  end

  private

  def host
    'http://api.localhost.com:3000'
  end

end
