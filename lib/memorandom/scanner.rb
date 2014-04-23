module Memorandom
  class Scanner

    require 'fileutils'
    require 'openssl'
    require 'yaml'

    attr_accessor :plugins, :source
    attr_accessor :window, :overlap, :output

    def initialize(opts={})
      plugin_names = Memorandom::PluginManager.plugins.keys

      # Allow only a subset of plugins to be selected
      if opts[:plugins]
        plugin_names = Memorandom::PluginManager.plugins.keys.select{ |name|  
          opts[:plugins].include?(name) 
        }
      end

      # Load the selected plugins
      self.plugins = plugin_names.map { |name|
        Memorandom::PluginManager.plugins[name].new(self)
      }

      self.window  = opts[:window]  || 1024*1024
      self.overlap = opts[:overlap] || 1024*4
      self.output  = opts[:output]

      FileUtils.mkdir_p(self.output) if self.output

    end

    def scan(target, source_name = nil)
      fd = nil

      if target.respond_to?(:read)
        self.source = source_name || target.to_s
      else
        case target
        when '-'
          fd = $stdin
          self.source = source_name || '<stdin>'
        else
          unless ( File.file?(target) or File.blockdev?(target) or File.chardev?(target) )
            display("[-] Skipping #{target}: not a file")
            return
          end
          begin
            fd = File.open(target, "rb")
            self.source = source_name ||"file:#{target.dup}"
          rescue ::Interrupt
            raise $!
          rescue ::Exception
            display("[-] Skipping #{target}: #{$!.class} #{$!}")
            return
          end
        end
      end

      # Reset the plugin state between each target
      self.plugins.each { |plugin| plugin.reset }

      buffer = fd.read(self.window)
      offset = 0

      # Skip empty sources (an empty first read)
      return unless buffer

      while buffer.length > 0

        self.plugins.each do |plugin|
          # display("[*] Scanning #{buffer.length} bytes at offset #{offset}")

          # Track a temporary per-plugin buffer and offset
          scan_buffer = buffer
          scan_offset = offset 

          # Adjust the buffer and offset if any hits have been found that are 
          # greater than offset. This is required because of overlap between 
          # search windows. It is rare, but should be handled here so that
          # plugins don't have to worry about it.

          adjust = plugin.hits.keys.select{|hit| hit > offset }.last
          if adjust
            start_index = ( adjust - offset + 1 )
            scan_buffer = buffer[start_index, buffer.length-start_index]
            scan_offset += start_index
          end

          # Scan the buffer with the plugin
          plugin.scan(scan_buffer, scan_offset)
        end

        # Calculate the next sliding window 
        seeked = self.window - self.overlap
        offset += seeked

        nbytes = fd.read(seeked)
        break if not nbytes

        # Append new data to the end of the buffer
        buffer << nbytes

        # Delete most of the previous data from the beginning
        buffer[0, seeked] = ''
      end

      # Close the file descriptor if we opened it
      fd.close if source =~ /^file:/
    end

    def report_hit(info)
      unless self.output
        display("[+] #{source} #{info[:type]}@#{info[:offset]} (#{info[:data][0,32].inspect}...)")
        return
      end

      fname = source.split("/").last[0,128] + "_"
      fname << info[:data][0,16].unpack("H*").first
      fname << "_#{info[:offset]}.#{info[:type]}"
      yname = fname + ".yml"

      fname = clean_filename(fname)
      yname = clean_filename(yname)

      fpath = ::File.join(self.output, fname)
      ::File.open(fpath, "wb") { |fd| fd.write(info[:data]) }

      display("[+] #{source} #{info[:type]}@#{info[:offset]} (#{info[:data][0,32].inspect}) stored in #{fpath}")

      ypath = ::File.join(self.output, yname)
      yhash = { 
        :source    => source, 
        :type      => info[:type], 
        :offset    => info[:offset], 
        :timestamp => Time.now,
        :length    => info[:data].length
      }
      ::File.open(ypath, "wb") { |fd| fd.write(yhash.to_yaml) }

    end

    def clean_filename(name)
      name.gsub(/[^a-zA-Z0-9_\.\-]/, '_').gsub(/_+/, '_')
    end

    def display(str)
      $stdout.puts(str)
    end
  end
end