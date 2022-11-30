require "xmlrpc/client"
class Api::OdooController < ApplicationController

    def index 
        begin

            url = "https://kareem-crm.odoo.com"
            db = "kareem-crm"
            username = "div.kareemomar@gmail.com"
            password = "01094976280"

            common = XMLRPC::Client.new2("#{url}/xmlrpc/2/common")
            uid = common.call('authenticate', db, username, password, {})
            models = XMLRPC::Client.new2("#{url}/xmlrpc/2/object").proxy

            record = models.execute_kw(db, uid, password, 'crm.lead', 'search_read', [[['phone_sanitized', '=', params[:phone]]]], {fields: %w(id name),limit: 1})
        

            if record.length > 0
                id = record[0]['id']

                models.execute_kw(db, uid, password, 'crm.lead', 'write', [[id], {'type': "opportunity"}])
                updated =  models.execute_kw(db, uid, password, 'crm.lead', 'name_get', [[id]])

                render json:{'status'=>'success','result' => updated}     
            else
                params[:name] ?  name = params[:name]  : name = 'New Partner'

                partner_id = models.execute_kw(db, uid, password, 'res.partner', 'create', [{name: name}])
                lead_id = models.execute_kw(db, uid, password, 'crm.lead', 'create', [{name: name,partner_id: partner_id ,phone:params[:phone] ,phone_sanitized: params[:phone]}])

                render json:{'status'=>'success','partner_id' => lead_id}  
            end

        rescue StandardError => e
            render json:['status'=>'error','message' => e] 
        end
    end


end
