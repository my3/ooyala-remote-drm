require 'ooyala-v2-api'

class Fairplay
	def request_key(api, embed_code)
		generate_keys(api, embed_code, get_key_version(api, embed_code))
	end

	def get_key_version(api, embed_code)
		key_response = api.get("assets/#{embed_code}/drm_attributes/fps")

		numKeys = 0
		key_response.each do |key, value|
			if key.include?("fps_content_key")
				numKeys += 1
			end
		end

		version = (numKeys / 2) + 1
	end

	def generate_keys(api, embed_code, version)
		key_response = api.post("assets/#{embed_code}/drm_attributes/fps", nil, { "version" => version })
		
		key_to_find = "fps_content_key_#{version}"
		iv_to_find = "fps_content_key_iv_#{version}"

		base64_key = ""
		base64_iv = ""

		key_response.each do |key, value|
			if key == key_to_find
				if value.include?("*")
					return {"error": "Error generating keys. Please try again in a couple minutes"}
				end

				base64_key = value
			elsif key == iv_to_find
				base64_iv = value
			end
		end

		hex_key = bin_to_hex(base64_key)
		hex_iv = bin_to_hex(base64_iv)

		{"key": "#{hex_key}", "iv": "#{hex_iv}", "skd": "skd://#{embed_code}|#{version}", "key_format": "com.apple.streamingkeydelivery"}
	end

	def bin_to_hex(s)
  		s.unpack("m0").first.unpack("H*").first
	end
end