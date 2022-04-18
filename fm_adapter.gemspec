lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fm_adapter/version'

Gem::Specification.new do |gem|
  gem.name          = 'fm_adapter'
  gem.version       = FmTimbradoCfdi::VERSION
  gem.authors       = ['Gabriel Edera', 'Facundo Condori', 'Franco Sanchez']
  gem.email         = ['gab.edera@gmail.com']
  gem.homepage      = 'https://github.com/gedera/fm_adapter'
  gem.summary       = %q{Implementación en ruby de la conexión con el servicio de timbrado de cfdi con el PAC Facturación Moderna}
  gem.description   = 'Implementación en Ruby de la Conexión con el Servicio de Timbrado de CFDI con el PAC: Facturación Moderna'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency('nokogiri', ['~> 1.10.9'])
  gem.add_dependency('savon', ['~> 2.12.0'])

  gem.add_development_dependency 'rspec'
end
