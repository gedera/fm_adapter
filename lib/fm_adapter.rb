require 'fm_adapter/version'
require 'fm_adapter/fm_cliente'
require 'fm_adapter/fm_informacion_cfdi'
require 'fm_adapter/fm_cfdi'
require 'nokogiri'
require 'base64'

module FmTimbradoCfdi
  extend self

  def configurar
    yield cliente
  end

  def cliente
    @cliente ||= FmCliente.new
  end

  # Public: Envía un archivo al PAC para ser timbrado en formato xml
  #
  # xml - Es el archivo XML sellado como un string
  # generar_cbb - Es una bandera que indica si debe generarse el código cbb, por default es false
  #
  # Regresa un objeto tipo FMRespuesta que contiene el xml certificado, el timbre y la representación en pdf o el cbb en png
  def timbra_cfdi_xml (xml, generar_cbb = false)
    factura_xml = Nokogiri::XML(xml)
    #procesar rfc del emisor
    emisor = factura_xml.xpath('//cfdi:Emisor')
    rfc = emisor[0]['rfc']
    cliente.timbrar rfc, factura_xml.to_s, 'generarCBB' => generar_cbb
  end

  # Public: Envía un archivo al PAC para ser timbrado en formato layout
  #
  # rfc - Es el RFC del emisor
  # layout - Es el archivo layout a ser timbrado como un string
  # generar_cbb - Es una bandera que indica si debe generarse el código cbb, por default es false
  #
  # Regresa un objeto tipo FMRespuesta que contiene el xml certificado, el timbre y la representación en pdf o el cbb en png
  def timbra_cfdi_layout (rfc, layout, generar_cbb = false)
    cliente.timbrar rfc, layout, 'generarCBB' => generar_cbb
  end

  # Public: Envía un archivo al PAC para ser timbrado tanto en formato layout como en formato XML
  #
  # rfc - Es el RFC del emisor
  # archivo - Es el archivo a ser timbrado como un string
  # opciones - Es un hash de opciones que deben coincidir con los parámetros recibidos por Facturación Moderna para el timbrado
  #
  # Regresa un objeto tipo FMRespuesta que contiene el xml certificado, el timbre y la representación en pdf o el cbb en png
  def timbrar (rfc, archivo, opciones= {})
    cliente.timbrar rfc, archivo, opciones
  end

  # Public: Envía CSD para que lo almacene el PAC
  #
  # rfc - Es el RFC del emisor
  # certificado - El contenido del archivo de certificado
  # llave - La llave privada del certificado
  # password - Contraseña de la llave privada
  #
  # Regresa un objeto de tipo FmRespuestaCancelacion
  def activar_cancelacion(rfc, certificado, llave, password)
    cliente.subir_certificado rfc, certificado, llave, password
  end
  alias :subir_certificado :activar_cancelacion

  # Public: Envía una petición de cancelación de factura
  #
  # rfc - Es el RFC del emisor
  # uuid - Es el identificador de la factura a cancelar
  #
  # Regresa una respuesta SOAP
  #
  # en opciones se debe enviar:
  # { 'Motivo' => op1,
  #   'FolioSustitucion' => Folio Fiscal del comprobante que lo sustituye (solo si Motivo es 01) }
  #
  # Motivo puede ser:
  # 01 - Comprobantes emitidos con errores con relación
  # 02 - Comprobantes emitidos con errores sin relación
  # 03 - No se llevó a cabo la operación
  # 04 - Operación nominativa relacionada en una factura global
  def cancelar(rfc, uuid, opciones)
    cliente.cancelar(rfc, uuid, opciones)
  end
end
