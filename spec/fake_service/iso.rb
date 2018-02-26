module Hcloud
  module FakeService
    $ISOS = {
      "isos"=>[
        {
          "id"=>26, 
          "name"=>"virtio-win-0.1.141.iso", 
          "description"=>"virtio 0.1.141-1", 
          "type"=>"public", 
          "deprecated"=>nil
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

    class ISO < Grape::API
      group :isos do
        params do
          requires :id, type: Integer
        end
        route_param :id do
          before_validation do
            @x = $ISOS["isos"].find{|x| x["id"].to_s == params[:id].to_s }
            error!({error: {code: :not_found}}, 404) if @x.nil?
          end
          get do
            { iso: @x }
          end
        end
        
        params do
          optional :name, type: String
        end
        get do
          dc = $ISOS.deep_dup
          dc["isos"].select!{|x| x["name"] == params[:name] } if !params[:name].nil?
          dc
        end
      end
    end
  end
end
