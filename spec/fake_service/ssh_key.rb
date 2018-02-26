module Hcloud
  module FakeService
    $SSH_KEY_ID = 0
    $SSH_KEYS = {
      "ssh_keys"=>[
      ], 
      "meta"=>{
        "pagination"=>{
          "page"=>1, 
          "per_page"=>25, 
          "previous_page"=>nil, 
          "next_page"=>nil, 
          "last_page"=>1, 
          "total_entries"=>2
        }
      }
    }

    class SSHKey < Grape::API
      group :ssh_keys do
        params do
          requires :id, type: Integer
        end
        route_param :id do
          before_validation do
            @x = $SSH_KEYS["ssh_keys"].find{|x| x["id"].to_s == params[:id].to_s }
            error!({error: {code: :not_found}}, 404) if @x.nil?
          end
          get do
            { ssh_key: @x }
          end
        
          params do
            optional :name, type: String
          end
          put do 
            if params[:name].nil?
              error!({error: {code: :invalid_input}}, 400)
            end
            @x["name"] = params[:name]
            { ssh_key: @x }
          end
          
          delete do 
            $SSH_KEYS["ssh_keys"].delete(@x)
            @body = nil
            status 204
          end
        end
        
        params do
          optional :name, type: String
          optional :public_key, type: String
        end
        post do 
          if params[:name].nil?
            error!({error: {code: :invalid_input}}, 400)
          end
          unless params[:public_key].to_s.start_with?("ssh-")
            error!({error: {code: :invalid_input}}, 400)
          end
          if $SSH_KEYS["ssh_keys"].any?{|x| params[:public_key] == x["public_key"] }
            error!({error: {code: :uniqueness_error}}, 400)
          end
          if $SSH_KEYS["ssh_keys"].any?{|x| params[:name] == x["name"] }
            error!({error: {code: :uniqueness_error}}, 400)
          end
          key = {
            "id" => $SSH_KEY_ID+=1,
            "name" => params[:name],
            "fingerprint" => ('%x:'*15+'%x') % 0.upto(15).map{rand(0..255)},
            "public_key" => params[:public_key],
          }
          $SSH_KEYS["ssh_keys"] << key
          { ssh_key: key }
        end

        params do
          optional :name, type: String
        end
        get do
          unless params.has_key?(:name)
            $SSH_KEYS
          else
            dc = $SSH_KEYS.deep_dup
            dc["ssh_keys"].select!{|x| x["name"] == params[:name] }
            dc
          end
        end
      end
    end
  end
end
