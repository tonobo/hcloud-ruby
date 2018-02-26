module Hcloud
  module FakeService
    $FLOATING_IPS_IDS = 0
    $FLOATING_IPS = {
      "floating_ips"=>[
        {
          "id"=>595, 
          "description"=>"moo", 
          "ip"=>"94.130.188.60", 
          "type"=>"ipv4", 
          "server"=>nil, 
          "dns_ptr"=>[
            {
              "ip"=>"127.0.0.1", 
              "dns_ptr"=>"static.1.0.0.127.clients.your-server.de"
            }
          ], 
          "home_location"=>{
            "id"=>2, 
            "name"=>"nbg1", 
            "description"=>"Nuremberg DC Park 1", 
            "country"=>"DE", 
            "city"=>"Nuremberg", 
            "latitude"=>49.452102, 
            "longitude"=>11.076665
          }, 
          "blocked"=>false
        }
      ], 
      "meta"=>{
        "pagination"=>{
          "page"=>1, 
          "per_page"=>25, 
          "previous_page"=>nil, 
          "next_page"=>nil, 
          "last_page"=>1, 
          "total_entries"=>1
        }
      }
    }

    class FloatingIP < Grape::API
      group :floating_ips do
        params do
          requires :id, type: Integer
        end
        route_param :id do
          before_validation do
            @x = $FLOATING_IPS["floating_ips"].find{|x| x["id"].to_s == params[:id].to_s }
            error!({error: {code: :not_found}}, 404) if @x.nil?
          end
          get do
            { floating_ip: @x }
          end
          
          params do
            optional :description, type: String
          end
          put do
            @x["description"] = params[:description]
            { floating_ip: @x }
          end
          
          group :actions do
            params do
              optional :status, type: String
              optional :sort, type: String
            end
            get do
              dc = $ACTIONS.deep_dup
              dc["actions"].select! do |x|
                x["command"].to_s.include?("floating_ip") and
                x["resources"].to_a.any? do |y| 
                  y.to_h["type"] == "server" and 
                    y.to_h["id"].to_s == @x["server"].to_s
                end
              end
              if !params[:status].nil?
                dc["actions"].select! do |x| 
                  x["status"].to_s == params[:status].to_s
                end 
              end
              dc
            end
           
            params do
              optional :server, type: String
            end
            post :assign do
              a = { "action" => Action.add(command: "assign_floating_ip", status: "running", 
                                resources: [{id: @x["server"].to_i, type: "server"}])}
              @x["server"] = params[:server].to_i
              a
            end

            post :unassign do
              a = { "action" => Action.add(command: "unassign_floating_ip", status: "running", 
                                resources: [{id: @x["server"].to_i, type: "server"}])}
              @x["server"] = nil
              a
            end
          end
        
          delete do 
            $FLOATING_IPS["floating_ips"].delete(@x)
            @body = nil
            status 204
          end
        end
          
        params do
          optional :type, type: String
          optional :description, type: String
          optional :server, type: String
          optional :home_location, type: String
        end
        post do 
          unless %w[ipv4 ipv6].include?(params[:type])
            error!({error: {code: :invalid_input}}, 400)
          end
          if params[:home_location] and !%w[fsn1 nbg1].include?(params[:home_location])
            error!({error: {code: :invalid_input}}, 400)
          end
          if params[:server] and !params[:server].to_s[/^\d+$/]
            error!({error: {code: :invalid_input}}, 400)
          end
          action = nil
          if params[:server]
            action = Action.add(command: "assign_floating_ip", status: "running", 
                                resources: [{id: params[:server].to_i, type: "server"}])
          end
          params[:home_location] ||= "nbg1"
          f = {
            "id" => $FLOATING_IPS_IDS+=1, 
            "description" => params[:description],
            "ip" => "127.0.0.2", 
            "type" => params[:type],
            "blocked" => false,
            "server" => params[:server],
            "dns_ptr" => [
              {
                "ip"=>"127.0.0.2", 
                "dns_ptr"=>"static.2.0.0.127.clients.your-server.de"
              }
            ],
            "home_location" => $LOCATIONS["locations"].find{|x| x["name"] == params[:home_location]}
          }
          $FLOATING_IPS["floating_ips"] << f 
          if params[:server]
            {"action" => action, "floating_ip" => f}
          else
            {"floating_ip" => f}
          end
        end
          
        
        get do
          $FLOATING_IPS.deep_dup
        end
      end
    end
  end
end
