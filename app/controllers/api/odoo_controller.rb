require "xmlrpc/client"
class Api::OdooController < ApplicationController
    # before_action :authorize_request

    def index 
        begin

            # url = "https://kareem-crm.odoo.com"
            # db = "kareem-crm"
            # username = "div.kareemomar@gmail.com"
            # password = "01094976280"

            url = "https://safa-erp-staging-5994660.dev.odoo.com"
            db="safa-erp-staging-5994660"
            username = "admin"
            password = "2902fd832621fee6edb236e94e30bab1eca09eba"
            
            params[:phone].chr == '+' || params[:phone].chr == ' ' ?  phone = params[:phone].sub(params[:phone].chr,'+') : phone = '+'.concat(params[:phone])
            

           if Phoner::Phone.valid? phone
                phone = Phoner::Phone.parse(phone).to_s
           elsif 
                Phoner::Phone.default_country_code = '966'
                phone = Phoner::Phone.parse(params[:phone]).to_s
           end



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

        rescue StandardError => e
            render json:['status'=>'error','message' => e] 
        end
    end


end
