# frozen_string_literal: true

module Hcloud
  class SSHKeyResource < AbstractResource
    def all
      mj('ssh_keys') do |j|
        j.flat_map { |x| x['ssh_keys'].map { |x| SSHKey.new(x, self, client) } }
      end
    end

    def create(name:, public_key:)
      j = Oj.load(request('ssh_keys', j: { name: name, public_key: public_key }).run.body)
      SSHKey.new(j['ssh_key'], self, client)
    end

    def find(id)
      SSHKey.new(
        Oj.load(request("ssh_keys/#{id}").run.body)['ssh_key'],
        self,
        client
      )
    end

    def find_by(name:)
      x = Oj.load(request('ssh_keys', q: { name: name }).run.body)['ssh_keys']
      return nil if x.none?

      x.each do |s|
        return SSHKey.new(s, self, client)
      end
    end

    def [](arg)
      case arg
      when Integer
        begin
          find(arg)
        rescue Error::NotFound
        end
      when String
        find_by(name: arg)
      end
    end
  end
end
