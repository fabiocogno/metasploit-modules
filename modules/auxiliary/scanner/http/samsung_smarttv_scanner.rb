##
# This module requires Metasploit: http://metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##

require 'msf/core'

class MetasploitModule < Msf::Auxiliary
  include Msf::Exploit::Remote::HttpClient
  include Msf::Auxiliary::Scanner

  def initialize(info = {})
    super(update_info(info,
      'Name' => 'Samsung SmartTV Scanner',
      'Description' => %q({
        Detect Samsung SmartTV and returns informations about name, model, MSF version and more...
      }),
      'Author' => ['Fabio Cogno'], # Metasploit module
      'License' => MSF_LICENSE,
      'References' =>
          [
            ['URL', 'https://developer.samsung.com/tv/develop/extension-libraries/smart-view-sdk/receiver-apps/debugging']
          ],
      'DefaultOptions' => {
        'RHOSTS' => '192.168.1.1-255',
        'RPORT' => 8001
      }))

    register_options(
      [
        OptString.new('TARGETURI', [true, 'The base path to find MSF', '/api/v2/'])
      ]
    )
  end

  def run
    uri = target_uri.path

    res = send_request_cgi(
      'method' => 'GET',
      'uri' => uri,
      'version' => '1.1'
    )

    if res && res.code == 200
      print_good("[#{target_host}] - Samsung SmartTV found!")
      json = res.get_json_document
      print_status("Getting system information ...")
      print_status("\tThe model name is #{json['device']['modelName']}")
      print_status("\tThe model is #{json['device']['model']}")
      print_status("\tThe network type is #{json['device']['networkType']}")
      print_status("\tThe name is #{json['device']['name']}")
      print_status("\tThe country code is #{json['device']['countryCode']}")
      print_status("\tThe MSF Version is #{json['device']['msfVersion']}")
      if json['device']['developerMode'] == "0"
        print_status("\tThe developer mode is FALSE")
      else
        print_status("\tThe developer mode is TRUE")
        print_status("\tThe developer IP is #{json['device']['developerIP']}")
      end
    else
      print_error("[#{target_host}] - No response")
    end
  end
end
