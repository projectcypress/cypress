module Cypress
  class ArtifactManager

    #Helper that stores files like PQRIs and associates them with a test execution
    def self.grid()
        Mongoid::GridFS
    end
    def self.save_artifacts(*artifacts, test_execution)

      ids = []
      artifacts.each do |a|
       fs = grid.put(a.open, :filename => File.basename(a.path))
       fs.save
       ids << fs.id
      end
      ids
    end

    def self.del_artifacts(ids)
      ids.each do |id|
        grid.delete(id)
      end
    end

    def self.del_artifact(artifact_id)
      grid.delete(artifact_id)
    end


    def self.get_artifacts(artifact_ids)
      ids = [artifact_ids].flatten
      Mongoid::GridFS::Fs::File.in({"_id" => ids})
    end
    
  end
end