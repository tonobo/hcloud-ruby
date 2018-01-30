module Hcloud
  module FakeService
    $DATACENTERS = {
      "datacenters" => [
        {
          "id"=>1, 
          "name"=>"fsn1-dc8", 
          "description"=>"Falkenstein 1 DC 8", 
          "location" => {
            "id"=>1, 
            "name"=>"fsn1", 
            "description"=>"Falkenstein DC Park 1", 
            "country"=>"DE", 
            "city"=>"Falkenstein", 
            "latitude"=>50.47612, 
            "longitude"=>12.370071
          }, 
          "server_types"=>{
            "supported"=>[2, 4, 6, 8, 10, 9, 7, 5, 3, 1], 
            "available"=>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
          }
        }, {
          "id"=>2, 
          "name"=>"nbg1-dc3", 
          "description"=>"Nuremberg 1 DC 3", 
          "location"=>{
            "id"=>2, 
            "name"=>"nbg1", 
            "description"=>"Nuremberg DC Park 1", 
            "country"=>"DE", 
            "city"=>"Nuremberg", 
            "latitude"=>49.452102, 
            "longitude"=>11.076665
          }, 
          "server_types"=>{
            "supported"=>[2, 4, 6, 8, 10, 9, 7, 5, 3, 1], 
            "available"=>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
          }
        }
      ], 
      "recommendation"=>2, 
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

    class Datacenter < Grape::API
      group :datacenters do
        params do
          requires :id, type: Integer
        end
        route_param :id do
          get do
            x = $DATACENTERS["datacenters"].find{|x| x["id"] == params[:id] }
            error!({error: {code: :not_found}}, 404) if x.nil?
            { datacenter: x }
          end
        end

        params do
          optional :name, type: String
        end
        get do
          unless params.has_key?(:name)
            $DATACENTERS
          else
            if params[:name].to_s.include?("-")
              dc = $DATACENTERS.deep_dup
              dc["datacenters"].select!{|x| x["name"] == params[:name] }
              dc
            else
              error!({error: {code: :invalid_input}}, 400)
            end
          end
        end
      end
    end
  end
end
