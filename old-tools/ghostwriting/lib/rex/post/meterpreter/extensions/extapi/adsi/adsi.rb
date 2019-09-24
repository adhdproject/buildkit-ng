# -*- coding: binary -*-

module Rex
module Post
module Meterpreter
module Extensions
module Extapi
module Adsi

###
#
# This meterpreter extension contains extended API functions for
# querying and managing desktop windows.
#
###
class Adsi

  def initialize(client)
    @client = client
  end

  #
  # Perform a generic domain query against ADSI.
  #
  # @param domain_name [String] The FQDN of the target domain.
  # @param filter [String] The filter to apply to the query in
  #   LDAP format.
  # @param max_results [Integer] The maximum number of results
  #   to return.
  # @param page_size [Integer] The size of the page of results
  #   to return.
  # @param fields [Array] Array of string fields to return for
  #   each result found
  #
  # @return [Hash] Array of field names with associated results.
  #
  def domain_query(domain_name, filter, max_results, page_size, fields)
    request = Packet.create_request('extapi_adsi_domain_query')

    request.add_tlv(TLV_TYPE_EXT_ADSI_DOMAIN, domain_name)
    request.add_tlv(TLV_TYPE_EXT_ADSI_FILTER, filter)
    request.add_tlv(TLV_TYPE_EXT_ADSI_MAXRESULTS, max_results)
    request.add_tlv(TLV_TYPE_EXT_ADSI_PAGESIZE, page_size)

    fields.each do |f|
      request.add_tlv(TLV_TYPE_EXT_ADSI_FIELD, f)
    end

    response = client.send_request(request)

    results = []
    response.each(TLV_TYPE_EXT_ADSI_RESULT) { |r|
      result = []
      r.each(TLV_TYPE_EXT_ADSI_VALUE) { |v|
        result << v.value
      }
      results << result
    }

    return {
      :fields  => fields,
      :results => results
    }
  end

  attr_accessor :client

end

end; end; end; end; end; end

