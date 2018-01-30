module Hcloud
  class SSHKey
    Attributes = {
      id: nil,
      name: nil,
      fingerprint: nil,
      public_key: nil
    }
    include EntryLoader

    def update(name:)
      j = Oj.load(request("ssh_keys/#{id.to_i}", 
                          j: {name: name}, 
                          method: :put).run.body)
      SSHKey.new(j, self, client)
    end

    def destroy
      request("ssh_keys/#{id}", method: :delete).run.body
      true
    end

  end
end
