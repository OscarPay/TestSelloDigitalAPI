class InvoicesController < ApplicationController
  require 'rest-client'

  HOST = 'http://api.localhost.com:3000'.freeze
  ACCESS_TOKEN = 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJ1c2VyIjp7ImlkIjoyLCJuYW1lIjoiVmljdG9yIiwiZW52aXJvbWVudCI6ImRldmVsb3BtZW50IiwidGltZSI6MTQ2NzIxMjk2NH19.jGG_zMc-MqBrbBQh9WpWv9kA2vA9ciVJ75tDCt71tWAXUV_-6BMo5dTqH-08frDCIGBxgymqRE3FdhyK2E05Qw'.freeze
  ACCESS_TOKEN2 = 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJ1c2VyIjp7ImlkIjozLCJuYW1lIjoiSm9yZ2UiLCJlbnZpcm9tZW50IjoiZGV2ZWxvcG1lbnQiLCJ0aW1lIjoxNDY3MjIyNzI5fX0.8R3RC4WRIwQBM0MeCkrj0z8YGm6rtK9oWSqPeZgbJIBkX5dtQRIkjanHgO7b7tfUpM-2zWR6DxtBDKc3NTZceg'.freeze

  def index
    path = Rails.root.join("public", "invoices")
    Dir.mkdir(path) unless File.exist?(path)

    response = RestClient.get(HOST + '/invoices/9', {Authorization: ACCESS_TOKEN2})
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
    json_invoice = {invoice: {date: Time.zone.now,
                              payment_form: 'Pago en una sola exhibición.',
                              payment_conditions: 'muchas',
                              note: 'asdasd', discount_amount: 50, issuer_rfc: 'AAD990814BP7',
                              payment_method_id: 1, receipt_type_id: 2, money_id: 1,
                              receptor_rfc: 'PEAO941212A8A', branch_name: "OFFICE", is_test: 0,
                              invoice_type_id: 1, discount_type_id: 1,
                              concepts_attributes: {"0": {quantity: 4, unit: "hola mundo", price: 30,
                                                          description: "hdsda", iva_type_id: 1},
                                                    "1": {quantity: 5, unit: "hola mundo", price: 31,
                                                          description: "jejej", iva_type_id: 1}
                              }
    }}

    @response = RestClient.post(HOST + '/invoices', json_invoice, {Authorization: ACCESS_TOKEN2})
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
    json_invoice = {invoice: {date: Time.zone.now,
                              payment_form: 'Pago en una sola exhibición.',
                              payment_conditions: 'muchas',
                              note: 'asdasd', discount_amount: 50, issuer_rfc: 'AAD990914BP7',
                              payment_method_id: 1, receipt_type_id: 1, money_id: 1,
                              is_test: 0, invoice_type_id: 1, discount_type_id: 1,
                              branch_attributes: [name: "Sucursal prueba4456", phone: "9252525", serie: "V", folio: "25",
                                                  address_attributes: address_invoice],
                              receptor_attributes: [name: "Pruebas456", social_reason: "Prueba Reason", rfc: "PEAO031212A8A",
                                                    email: "test@hotmail.com", address_attributes: address_invoice],
                              concepts_attributes: {"0": {quantity: 4, unit: "hola mundo2", price: 30,
                                                          description: "hdsda", iva_type_id: 1},
                                                    "1": {quantity: 5, unit: "hola mundo2", price: 31,
                                                          description: "jejej", iva_type_id: 1}
                              }
    }}

    @response = RestClient.post(HOST + '/invoices/create_full', json_invoice, {Authorization: ACCESS_TOKEN2})
  end

  def edit
    @response = RestClient.get(HOST + "/invoices/#{params[:id]}/stamp", {Authorization: ACCESS_TOKEN2})
  end

  def destroy
    @response = RestClient.get(HOST + "/invoices/#{params[:id]}/cancel", {Authorization: ACCESS_TOKEN2})
  end

end
