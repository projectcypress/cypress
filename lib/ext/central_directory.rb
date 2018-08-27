module Zip
  class CentralDirectory
    def entries
      @entry_set.entries.reject do |entry|
        entry.symlink? ||
          Pathname.new(entry.name).absolute? ||
          # NOTE: This will reject a '..' anywhere in the filename.
          # The 'more robust' solution is a regex like /\.{2}(?:\/|\z)/
          entry.name.include?('..')
      end
    end
  end
end
