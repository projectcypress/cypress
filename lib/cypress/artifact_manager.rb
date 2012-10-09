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
       fs.attributes[:metadata] =  {:metadata => {'execution_id' => test_execution.id.to_s}}
       fs.save
       ids << fs.id
      end
      ids
    end

    def self.del_artifacts(test_execution)
      artifacts = grid.find(:metadata => {'execution_id' => test_execution.id.to_s})
      artifacts.each do |a|
        grid.delete(a['_id'])
      end
    end

    def self.del_artifact(artifact_id)
      grid.delete(artifact_id)
    end


    def self.get_artifacts(artifact_ids)
      ids = [artifact_ids].flatten
      ids.collect {|id| grid.get(id)}
     
    end
    
  end
end