# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_record/precounter/version'

Gem::Specification.new do |spec|
  spec.name          = 'activerecord-precounter'
  spec.version       = ActiveRecord::Precounter::VERSION
  spec.authors       = ['Takashi Kokubun']
  spec.email         = ['takashikkbn@gmail.com']

  spec.summary       = %q{Yet Another N+1 COUNT Query Killer for ActiveRecord}
  spec.description   = %q{Yet Another N+1 COUNT Query Killer for ActiveRecord}
  spec.homepage      = 'https://github.com/k0kubun/activerecord-precounter'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activerecord'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'mysql2'
  spec.add_development_dependency 'postgres'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'sqlite3'
end
