## ooyala-remote-drm

This sample script creates a Live RemoteAsset in Ooyala Backlot
and requests sample keys for HLS Fairplay and DASH Common Encryption.

Create a file called `config.json` in the root directory with following json data:

```
{
    "api_key": "API Key from Backlot",
    "api_secret": "API Secret from Backlot",
    "key_server": "keyserver.ooyala.com",
    "wv_aes_key": "Widevine Key provided by OTS team",
    "wv_aes_iv": "Widevine IV provided by OTS team",
    "wv_provider_id": "PCODE of the provider"
}
```

Running the script:

```
ruby main.rb
```

Sample Output generated:

```
Created a movie in Backlot with embed_code huOGVuYjE652t9CQx_qAblpmZMuPzX8S
Keys to use for HLS Fairplay: {"drm_type"=>"fps", "fps_content_key"=>"BoFl+gtAGNycBBWuUcjxGw==", "fps_content_key_iv"=>"iZzca9d3hI8+heXtB8pIYA=="}
Keys to use for DASH CENC: {:key=>"XAa0dgDF07IzgBf4oFYacQ==", :key_id=>"HX798fqtW1O5h3EdAA4/cQ==", :key_guid=>"f1fd7e1d-adfa-535b-b987-711d000e3f71"}
Encoded URLs added to the movie
```