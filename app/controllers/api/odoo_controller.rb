require "xmlrpc/client"
class Api::OdooController < ApplicationController
    # before_action :authorize_request

    def index 
        begin
            url = "https://safa-erp-staging-5791729.dev.odoo.com"
            db="safa-erp-staging-5791729"
            username = "admin"
            password = "317b1399a78081fd77534ce3fdc997d2cdd8d407"

            params[:phone].chr == '+' || params[:phone].chr == ' ' ?  phone = params[:phone].sub(params[:phone].chr,'+') : phone = '+'.concat(params[:phone])
            # abort phone

           if Phoner::Phone.valid? phone

                    phone = Phoner::Phone.parse(phone).to_s


                    common = XMLRPC::Client.new2("#{url}/xmlrpc/2/common")
                    uid = common.call('authenticate', db, username, password, {})
                    models = XMLRPC::Client.new2("#{url}/xmlrpc/2/object").proxy

                    record = models.execute_kw(db, uid, password, 'crm.lead', 'search_read', [[['phone_sanitized', '=', phone]]], {fields: %w(id name phone_sanitized phone),limit: 1})
                    # render json: record
                

                    if record.length > 0
                        id = record[0]['id']

                        models.execute_kw(db, uid, password, 'crm.lead', 'write', [[id], {'type': "opportunity"}])
                        updated =  models.execute_kw(db, uid, password, 'crm.lead', 'name_get', [[id]])

                        render json:{'status'=>'success','message' => 'updated lead type  successfully'}     
                    else
                        params[:name] ?  name = params[:name]  : name = 'New Lead'

                        partner_id = models.execute_kw(db, uid, password, 'res.partner', 'create', [{name: name}])
                        lead_id = models.execute_kw(db, uid, password, 'crm.lead', 'create', [{name: name,phone_sanitized: phone,partner_id: partner_id ,phone:phone}])

                        render json:{'status'=>'success','message' => 'created lead successfully'}  
                    end

            
           elsif 
             render json:{'status'=>'error','message' => 'The phone number is invalid'}  
            
           end


        rescue StandardError => e
            render json:['status'=>'error','message' => e] 
        end
    end


end
