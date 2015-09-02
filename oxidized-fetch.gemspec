Gem::Specification.new do |s|
  s.name              = 'oxidized-fetch'
  s.version           = '0.1.0'
  s.licenses          = %w( Apache-2.0 )
  s.platform          = Gem::Platform::RUBY
  s.authors           = [ 'Giovanni Lovato', 'Alex Tomasello' ]
  s.email             = %w( heruan@aldu.net )
  s.homepage          = 'http://github.com/heruan/oxidized-fetch'
  s.summary           = 'cli + library for scripting network devices'
  s.description       = 'rancid clogin-like script to push configs to devices + library interface to do same'
  s.rubyforge_project = s.name
  s.files             = `git ls-files`.split("\n")
  s.executables       = %w( oxf )
  s.require_path      = 'lib'

  s.add_runtime_dependency 'oxidized', '~> 0.2'
  s.add_runtime_dependency 'slop',     '~> 3.5'
end
