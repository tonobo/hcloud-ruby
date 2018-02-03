module Hcloud
  module FakeService
    $SERVER_ID = 0
    $SERVERS = {
      "servers"=>[
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

    class Server < Grape::API
      group :servers do
        params do
          requires :id, type: Integer
        end
        route_param :id do
          before_validation do
            @x = $SERVERS["servers"].find{|x| x["id"].to_s == params[:id].to_s }
            error!({error: {code: :not_found}}, 404) if @x.nil?
          end
          get do
            { server: @x }
          end
        
          params do
            optional :name, type: String
          end
          put do 
            if params[:name].nil?
              error!({error: {code: :invalid_input}}, 400)
            end
            @x["name"] = params[:name]
            { server: @x }
          end
          
          delete do 
            $SERVERS["servers"].delete(@x)
            Action.add(status: "success", command: "delete_server")
          end
        end

        params do
          optional :name, type: String
          optional :server_type, type: String
          optional :datacenter, type: String
          optional :location, type: String
          optional :start_after_create, type: Boolean
          optional :image, type: String
          optional :ssh_keys, type: Array[Integer]
          optional :user_data, type: String
        end
        post do
          server_type = nil
          datacenter = $DATACENTERS["datacenters"].first
          image = $IMAGES["images"].first
          if !params[:name].to_s[/^[A-Za-z0-9-]+$/]
            error!({error: {code: :invalid_input}}, 400)
          end
          if $SERVERS["servers"].any?{|x| x["name"] == params[:name]}
            error!({error: {code: :uniqueness_error}}, 400)
          end
          if $SERVER_TYPES["server_types"].none?{
              |x| server_type = x if [x["id"].to_s, x["name"]].include?(params[:server_type].to_s)}
            error!({error: {code: :invalid_input, message: "invalid server_type"}}, 400)
          end
          if $IMAGES["images"].none?{
              |x| image = x if [x["id"].to_s, x["name"]].include?(params[:image].to_s)}
            error!({error: {code: :invalid_input, message: "invalid image"}}, 400)
          end
          if !params[:datacenter].nil? && 
              $DATACENTERS["datacenters"].none?{|x|
               datacenter = x if [x["id"].to_s, x["name"]].include?(params[:datacenter].to_s)}
            error!({error: {code: :invalid_input, message: "invalid datacenter"}}, 400)
          end
          if !params[:location].nil? && 
              $LOCATIONS["locations"].none?{|x|
                [x["id"].to_s, x["name"]].include?(params[:location].to_s)}
            error!({error: {code: :invalid_input, message: "invalid location"}}, 400)
          end
          if params[:ssh_keys].to_a.any?{|id|
            $SSH_KEYS["ssh_keys"].none?{|x| id.to_s == x["id"].to_s}}
            error!({error: {code: :invalid_input, message: "invalid ssh key"}}, 400)
          end
          id = $SERVER_ID+=1
          s = {
            server: {
              id: id,
              name: params[:name],
              server_type: server_type,
              datacenter: datacenter,
              image: image,
              rescue_enabled: false,
              locked: false,
              backup_window: "22-02",
              outgoing_traffic: 123,
              ingoing_traffic: 123,
              included_traffic: 123,
              iso: nil,
              status: "initalizing",
              created: Time.now.iso8601,
              public_net: {
                ipv4: {
                  ip: "1.2.3.4",
                  blocked: false,
                  dns_ptr: "example.com",
                },
                ipv6: {
                  ip: "fe80::1/64",
                  blocked: false,
                  dns_ptr: [],
                },
                floating_ips: []
              }

            },
            action: Action.add(
              status: "running",
              command: "create_server",
              resources: [{id: id, type: :server}]
            ),
            root_password: "test123"
          }.deep_stringify_keys
          $SERVERS["servers"] << s["server"]
          Thread.new do 
            sleep(0.5)
            s["server"]["status"] = params[:start_after_create] ? "running" : "off"
            $ACTIONS["actions"].find{|x| x["id"] == s["action"]["id"]}["status"] = "success"
          end
          s
        end
        
        params do
          optional :name, type: String
        end
        get do
          dc = $SERVERS.deep_dup
          dc["servers"].select!{|x| x["name"] == params[:name] } if !params[:name].nil?
          dc
        end
      end
    end
  end
end
