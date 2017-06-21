require 'base64'
require 'digest/md5'
require 'httparty'
require 'openssl'

class WidevineModular
    def strict_encode64(bin)
        [bin].pack("m0").gsub("\n","")
    end
    
    def urlsafe_encode64(bin)
        strict_encode64(bin).tr("+/", "-_")
    end
    
    def strict_decode64(str)
        str.unpack("m0").first
    end

    def hex_to_binary(hex_string)
        [hex_string].pack("H*")
    end

    def openssl_aes_encrypt(data, key, iv, cipher_type = "AES-256-CBC")
        aes = OpenSSL::Cipher.new(cipher_type)
        aes.encrypt
        aes.key = hex_to_binary(key)
        aes.iv = hex_to_binary(iv) if iv != nil
        aes.update(data) + aes.final
    end

    
    def request_key(url, provider_key, provider_iv, pcode, embed_code)
        en_embed_code = strict_encode64(embed_code)
        
        message = {"content_id" => "#{en_embed_code}",
        "drm_types" => ["WIDEVINE", "PLAYREADY"] ,
        "first_crypto_period_index"=>0,
        "tracks"=>[{"type"=>"SD"},{"type"=>"HD"},{"type"=>"AUDIO"}],
        "crypto_period_count"=>1}.to_json
        
        request = urlsafe_encode64(message)
        sign = Digest::SHA1.digest(message)
        
        sign = openssl_aes_encrypt(sign, provider_key, provider_iv)
        sign = strict_encode64(sign)
        body_key_server = {"request"=>request,"signature"=>sign,"signer"=>"#{pcode}"}.to_json
        key_headers = {}
        key_response = HTTParty.send(:post, "https://#{url}/v1/providers/widevine_modular", :headers => key_headers, :body => body_key_server)
        
        key_response = JSON.parse(key_response)
        
        resp = Base64::decode64(key_response['response'])
        resp = JSON.parse(resp)
        
        key_id = resp['tracks'].first['key_id']
        key_id_parts = key_id.unpack("m0").first.unpack("H8H4H4H4H12")
        
        inverse_key_parts = key_id.unpack("m0").first.unpack("h8h4h4H4H12")
        inverse_key_parts.each_index do |index|
            inverse_key_parts[index].reverse! if index < 3
        end
        inverse_hex = inverse_key_parts.join('')
        inverse_key_id = [[inverse_hex].pack("H*")].pack("m0")
        
        key_guid = key_id_parts.join('-')
        key_id = inverse_key_id
        # Same with key. decode64 and convert to binary to get the 16 bytes
        key = resp["tracks"].first["key"]
        key = strict_decode64(resp["tracks"].first["key"])
        
        key = Base64.strict_encode64(key)
        {"key": "#{key}", "key_id": "#{key_id}", "key_guid": "#{key_guid}"}
    end
end