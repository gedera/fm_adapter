require 'nokogiri'
require 'savon'
require 'fm_adapter/fm_timbre'

module FmTimbradoCfdi
  class FmRespuesta
    attr_reader :errors, :pdf, :xml, :cbb, :timbre, :no_csd_emisor, :raw

    def initialize(response)
      @errors = []
      if response.is_a? String
        @raw = response
        procesar_respuesta(response)
      else
        parse_savon(response)
      end
    end

    def parse_savon(savon_response)
      if savon_response.success?
        @raw = savon_response.to_xml
        procesar_respuesta(savon_response.to_xml)
      else
        @errors << savon_response.soap_fault.to_s if savon_response.soap_fault?
        @doc = @xml = @no_csd_emisor = @timbre = @pdf = @cbb = nil
      end
    rescue Exception => e
      @errors << "No se ha podido realizar el parseo de la respuesta. #{e.message}"
    end

    def valid?
      @errors.empty?
    end

    def xml?
      !!@xml
    end

    def cbb?
      !!@cbb
    end

    def pdf?
      !!@pdf
    end

    def timbre?
      !!@timbre
    end

    def no_csd_emisor?
      !!@no_csd_emisor
    end

    alias xml_present? xml?
    alias cbb_present? cbb?
    alias pdf_present? pdf?
    alias timbre_present? timbre?
    alias no_csd_emisor_present? no_csd_emisor?

    private

    def procesar_respuesta(respuesta_xml)
      @doc = Nokogiri::XML(respuesta_xml)
      @xml = obtener_xml(@doc)
      @no_csd_emisor = obtener_no_csd_emisor(@xml) if @xml
      @timbre = obtener_timbre(@xml)
      @pdf = obtener_pdf(@doc)
      @cbb = obtener_cbb(@doc)
    end

    def obtener_xml(doc)
      return sin_nodo_xml if doc.xpath('//xml').empty?

      Base64.decode64(doc.xpath('//xml')[0].content)
    end

    def sin_nodo_xml
      @errors << 'No se ha encontrado el nodo xml'
      nil
    end

    def obtener_timbre(xml)
      FmTimbre.new(xml) if xml
    end

    def obtener_pdf(doc)
      Base64.decode64(doc.xpath('//pdf')[0].content) unless doc.xpath('//pdf').empty?
    end

    def obtener_cbb(doc)
      Base64.decode64(doc.xpath('//png')[0].content) unless doc.xpath('//png').empty?
    end

    def obtener_no_csd_emisor(xml)
      factura_xml = Nokogiri::XML(xml)
      if factura_xml.xpath('//cfdi:Comprobante').attribute('NoCertificado')
        factura_xml.xpath('//cfdi:Comprobante').attribute('NoCertificado').value
      else
        @errors << 'No se ha podido obtener el CSD del emisor'
        nil
      end
    end
  end
end
