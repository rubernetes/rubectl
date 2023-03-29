class GemGenerator
  def initialize
    @gem_file = <<~HEREDOC
    # frozen_string_literal: true
    
    source 'https://rubygems.org'
    
    gem 'rubernetes', '~> 1.0'
    gem 'rubocop', '~> 1.12', require: false
    HEREDOC
    @gem_lock_file = <<~HEREDOC
    GEM
      remote: https://rubygems.org/
      specs:
        addressable (2.8.1)
          public_suffix (>= 2.0.2, < 6.0)
        ast (2.4.2)
        domain_name (0.5.20190701)
          unf (>= 0.0.5, < 1.0.0)
        ffi (1.15.5)
        ffi-compiler (1.0.1)
          ffi (>= 1.0.0)
          rake
        http (5.1.1)
          addressable (~> 2.8)
          http-cookie (~> 1.0)
          http-form_data (~> 2.2)
          llhttp-ffi (~> 0.4.0)
        http-accept (1.7.0)
        http-cookie (1.0.5)
          domain_name (~> 0.5)
        http-form_data (2.3.0)
        json (2.6.3)
        jsonpath (1.1.2)
          multi_json
        kubeclient (4.11.0)
          http (>= 3.0, < 6.0)
          jsonpath (~> 1.0)
          recursive-open-struct (~> 1.1, >= 1.1.1)
          rest-client (~> 2.0)
        llhttp-ffi (0.4.0)
          ffi-compiler (~> 1.0)
          rake (~> 13.0)
        logger (1.5.3)
        mime-types (3.4.1)
          mime-types-data (~> 3.2015)
        mime-types-data (3.2023.0218.1)
        multi_json (1.15.0)
        netrc (0.11.0)
        parallel (1.22.1)
        parser (3.2.1.0)
          ast (~> 2.4.1)
        public_suffix (5.0.1)
        rainbow (3.1.1)
        rake (13.0.6)
        recursive-open-struct (1.1.3)
        regexp_parser (2.7.0)
        rest-client (2.1.0)
          http-accept (>= 1.7.0, < 2.0)
          http-cookie (>= 1.0.2, < 2.0)
          mime-types (>= 1.16, < 4.0)
          netrc (~> 0.8)
        rexml (3.2.5)
        rubernetes (1.0.0)
          kubeclient
          logger
        rubocop (1.46.0)
          json (~> 2.3)
          parallel (~> 1.10)
          parser (>= 3.2.0.0)
          rainbow (>= 2.2.2, < 4.0)
          regexp_parser (>= 1.8, < 3.0)
          rexml (>= 3.2.5, < 4.0)
          rubocop-ast (>= 1.26.0, < 2.0)
          ruby-progressbar (~> 1.7)
          unicode-display_width (>= 2.4.0, < 3.0)
        rubocop-ast (1.27.0)
          parser (>= 3.2.1.0)
        ruby-progressbar (1.11.0)
        unf (0.1.4)
          unf_ext
        unf_ext (0.0.8.2)
        unicode-display_width (2.4.2)

    PLATFORMS
      x86_64-darwin-21

    DEPENDENCIES
      rubernetes (~> 1.0)
      rubocop (~> 1.12)

    BUNDLED WITH
       2.3.12
    HEREDOC
  end

  def generate
    File.write("Gemfile", @gem_file)
    File.write("Gemfile.lock", @gem_lock_file)
  end
end